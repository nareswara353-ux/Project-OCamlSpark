#include "ocaml_glue.h"
#include "actuator_bridge.h"
#include <stdbool.h>
#include <string.h>

static glue_flight_mode_t current_mode = GLUE_MANUAL;
static bool trajectory_active = false;
static limits_t global_limits = {0.95, -0.95};
static actuator_state_t controller_state = {0};

actuator_cmd_t glue_send_trajectory_point(setpoint_t point, float max_rate) {
    ocaml_command_t cmd = {
        .deflection = point.position,
        .rate_limit = max_rate
    };
    command_t spark_cmd = bridge_command_to_spark(cmd);
    controller_state = spark_step(controller_state, spark_cmd);
    actuator_cmd_t result = {
        .target_deflection = controller_state.current_deflection,
        .rate_limit = spark_cmd.rate_limit
    };
    trajectory_active = true;
    return result;
}

actuator_cmd_t glue_finalize_trajectory(trajectory_data_t trajectory) {
    (void)trajectory;
    trajectory_active = false;
    actuator_cmd_t result = {
        .target_deflection = controller_state.current_deflection,
        .rate_limit = 0.0
    };
    return result;
}

void glue_abort_trajectory(void) {
    trajectory_active = false;
    controller_state = spark_emergency_stop(controller_state);
}

bool glue_is_trajectory_active(void) {
    return trajectory_active;
}

glue_flight_mode_t glue_get_current_mode(void) {
    return current_mode;
}

void glue_set_mode(glue_flight_mode_t mode) {
    current_mode = mode;
    if (mode == GLUE_EMERGENCY) {
        controller_state = spark_emergency_stop(controller_state);
    }
}

actuator_cmd_t glue_get_emergency_command(float deflection) {
    ocaml_command_t cmd = {
        .deflection = deflection,
        .rate_limit = 0.01
    };
    command_t spark_cmd = bridge_command_to_spark(cmd);
    controller_state = spark_emergency_stop(controller_state);
    actuator_cmd_t result = {
        .target_deflection = deflection,
        .rate_limit = 0.01
    };
    return result;
}

float glue_get_min_deflection(void) {
    return global_limits.min_deflection;
}

float glue_get_max_deflection(void) {
    return global_limits.max_deflection;
}

bool glue_validate_external_command(float deflection, float rate) {
    ocaml_command_t cmd = {deflection, rate};
    return bridge_validate_ocaml_command(cmd, global_limits.max_deflection, global_limits.min_deflection);
}
