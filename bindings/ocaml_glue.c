#include "ocaml_glue.h"
#include "actuator_bridge.h"
#include <stdbool.h>
#include <string.h>

static glue_flight_mode_t current_mode = GLUE_MANUAL;
static bool trajectory_active = false;
static limits_t global_limits = {0.95, -0.95};
static actuator_state_t controller_state = {0};

actuator_cmd_t glue_send_trajectory_point(setpoint_t point, double max_rate) {
    ocaml_command_t cmd = { point.position, max_rate };
    command_t spark_cmd = bridge_command_to_spark(cmd);
    controller_state = spark_step(controller_state, spark_cmd);
    actuator_cmd_t result = { controller_state.current_deflection, spark_cmd.rate_limit };
    trajectory_active = true;
    return result;
}

actuator_cmd_t glue_finalize_trajectory(trajectory_data_t trajectory) {
    (void)trajectory;
    trajectory_active = false;
    actuator_cmd_t result = { controller_state.current_deflection, 0.0f };
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

actuator_cmd_t glue_get_emergency_command(double deflection) {
    controller_state = spark_emergency_stop(controller_state);
    actuator_cmd_t result = { deflection, 0.01f };
    return result;
}

double glue_get_min_deflection(void) {
    return global_limits.min_deflection;
}

double glue_get_max_deflection(void) {
    return global_limits.max_deflection;
}

bool glue_validate_external_command(double deflection, double rate) {
    return spark_validate_command(
        0.0f, deflection, rate,
        global_limits.max_deflection, global_limits.min_deflection);
}
