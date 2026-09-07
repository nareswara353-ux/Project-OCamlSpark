#include "actuator_ffi.h"
#include "core_spark/actuator_commands.ads"
#include "core_spark/redundancy_voter.ads"
#include "core_spark/health_monitor.ads"
#include "core_spark/actuator_limits.ads"

bool validate_command(float current, float target, float max_rate, float max_def, float min_def) {
    limits_t lim = {max_def, min_def};
    command_t cmd = {target, 1.0};
    return Actuator_Commands.Validate_Command(current, target, lim, max_rate);
}

command_t apply_limits(command_t cmd, limits_t limits) {
    return Actuator_Commands.Apply_Limits(cmd, limits);
}

bool is_within_limits(float value, limits_t limits) {
    return Actuator_Limits.Is_Deflection_Safe(value, limits);
}

health_status_t check_overall_status(uint8_t pos_status, uint8_t temp_status, uint8_t curr_status, uint8_t hyd_status) {
    Channel_Health h = {
        .Position = (Sensor_Health)pos_status,
        .Temperature = (Sensor_Health)temp_status,
        .Current = (Sensor_Health)curr_status,
        .Hydraulic = (Sensor_Health)hyd_status
    };
    return (health_status_t)Health_Monitor.Overall_Status(h);
}

command_t majority_vote(command_t c1, command_t c2, command_t c3, limits_t limits) {
    return Redundancy_Voter.Majority_Vote(c1, c2, c3, limits);
}

bool is_consensus(command_t c1, command_t c2, command_t c3, float tolerance) {
    return Redundancy_Voter.Is_Consensus(c1, c2, c3, tolerance);
}
