#include "actuator_bridge.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

command_t bridge_command_to_spark(ocaml_command_t cmd) {
    command_t result;
    result.target_deflection = cmd.deflection;
    result.rate_limit = cmd.rate_limit;
    return result;
}

limits_t bridge_limits_to_spark(float max_def, float min_def) {
    limits_t result;
    result.max_deflection = max_def;
    result.min_deflection = min_def;
    return result;
}

actuator_state_t bridge_state_to_spark(ocaml_state_t state) {
    actuator_state_t result;
    result.current_deflection = state.position;
    result.current_mode = IDLE;
    result.last_command.target_deflection = 0.0;
    result.last_command.rate_limit = 0.0;
    result.health = HEALTHY;
    result.limit.max_deflection = 1.0;
    result.limit.min_deflection = -1.0;
    return result;
}

ocaml_state_t bridge_state_from_spark(actuator_state_t state) {
    ocaml_state_t result;
    result.position = state.current_deflection;
    result.velocity = 0.0;
    result.acceleration = 0.0;
    result.timestamp = 0.0;
    return result;
}

ocaml_command_t bridge_command_from_spark(command_t cmd) {
    ocaml_command_t result;
    result.deflection = cmd.target_deflection;
    result.rate_limit = cmd.rate_limit;
    return result;
}

bool bridge_validate_ocaml_command(ocaml_command_t cmd, float max_def, float min_def) {
    command_t spark_cmd = bridge_command_to_spark(cmd);
    limits_t limits = bridge_limits_to_spark(max_def, min_def);
    return spark_validate_command(0.0, spark_cmd.target_deflection, spark_cmd.rate_limit, max_def, min_def);
}

ocaml_command_t bridge_apply_ocaml_limits(ocaml_command_t cmd, float max_def, float min_def) {
    command_t spark_cmd = bridge_command_to_spark(cmd);
    limits_t limits = bridge_limits_to_spark(max_def, min_def);
    command_t result = spark_apply_limits(spark_cmd, limits);
    return bridge_command_from_spark(result);
}

ocaml_command_t bridge_majority_vote_ocaml(ocaml_command_t c1, ocaml_command_t c2, ocaml_command_t c3, float max_def, float min_def) {
    command_t spark_c1 = bridge_command_to_spark(c1);
    command_t spark_c2 = bridge_command_to_spark(c2);
    command_t spark_c3 = bridge_command_to_spark(c3);
    limits_t limits = bridge_limits_to_spark(max_def, min_def);
    command_t result = spark_majority_vote(spark_c1, spark_c2, spark_c3, limits);
    return bridge_command_from_spark(result);
}

bool bridge_is_consensus_ocaml(ocaml_command_t c1, ocaml_command_t c2, ocaml_command_t c3, float tolerance) {
    command_t spark_c1 = bridge_command_to_spark(c1);
    command_t spark_c2 = bridge_command_to_spark(c2);
    command_t spark_c3 = bridge_command_to_spark(c3);
    return spark_is_consensus(spark_c1, spark_c2, spark_c3, tolerance);
}

void bridge_log_command(ocaml_command_t cmd) {
    printf("Command: deflection=%.3f, rate_limit=%.3f\n", cmd.deflection, cmd.rate_limit);
}

void bridge_log_state(ocaml_state_t state) {
    printf("State: pos=%.3f, vel=%.3f, acc=%.3f, ts=%.3f\n", 
           state.position, state.velocity, state.acceleration, state.timestamp);
}
