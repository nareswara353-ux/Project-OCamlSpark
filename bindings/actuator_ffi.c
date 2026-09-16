#include "actuator_ffi.h"

void ocaml_force_link(void) { }

extern bool spark_validate_command(float current, float target, float max_rate, float max_def, float min_def);
extern command_t spark_apply_limits(command_t cmd, limits_t limits);
extern bool spark_is_within_limits(float value, limits_t limits);
extern int spark_check_overall_status(int pos, int temp, int curr, int hyd);
extern command_t spark_majority_vote(command_t c1, command_t c2, command_t c3, limits_t limits);
extern bool spark_is_consensus(command_t c1, command_t c2, command_t c3, float tolerance);
extern float spark_get_current_deflection(int id);
extern float spark_get_temperature(int id);
extern float spark_get_hydraulic_pressure(int id);
extern int spark_get_overall_status(int id);
extern bool spark_allocate_power(int id, float required_power);
extern bool spark_is_bus_overloaded(int bus);
extern bool spark_shed_load(int bus, int id);
extern int spark_get_power_status(int id);
extern bool spark_is_safe(unsigned char* state_ptr);

bool validate_command(float current, float target, float max_rate, float max_def, float min_def) {
    return spark_validate_command(current, target, max_rate, max_def, min_def);
}

command_t apply_limits(command_t cmd, limits_t limits) {
    return spark_apply_limits(cmd, limits);
}

bool is_within_limits(float value, limits_t limits) {
    return spark_is_within_limits(value, limits);
}

health_status_t check_overall_status(uint8_t pos_status, uint8_t temp_status, uint8_t curr_status, uint8_t hyd_status) {
    int result = spark_check_overall_status((int)pos_status, (int)temp_status, (int)curr_status, (int)hyd_status);
    if (result == 0) return HEALTHY;
    if (result == 1) return DEGRADED;
    return FAILED;
}

command_t majority_vote(command_t c1, command_t c2, command_t c3, limits_t limits) {
    return spark_majority_vote(c1, c2, c3, limits);
}

bool is_consensus(command_t c1, command_t c2, command_t c3, float tolerance) {
    return spark_is_consensus(c1, c2, c3, tolerance);
}
