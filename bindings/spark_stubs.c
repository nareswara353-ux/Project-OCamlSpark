#include "spark_export.h"

bool spark_validate_command(double current, double target, double max_rate, double max_def, double min_def) {
    (void)current; (void)max_rate;
    return target >= min_def && target <= max_def;
}

void spark_apply_limits(const command_t* cmd, const limits_t* limits, command_t* out) {
    command_t r = *cmd;
    if (r.target_deflection > limits->max_deflection) r.target_deflection = limits->max_deflection;
    if (r.target_deflection < limits->min_deflection) r.target_deflection = limits->min_deflection;
    *out = r;
}

bool spark_is_within_limits(double value, const limits_t* limits) {
    return value >= limits->min_deflection && value <= limits->max_deflection;
}

int spark_check_overall_status(int pos, int temp, int curr, int hyd) {
    (void)temp; (void)curr; (void)hyd;
    return pos == 2 ? 2 : 0;
}

void spark_majority_vote(const command_t* c1, const command_t* c2, const command_t* c3, const limits_t* limits, command_t* out) {
    (void)limits;
    double v1 = c1->target_deflection;
    double v2 = c2->target_deflection;
    double v3 = c3->target_deflection;
    command_t r = *c1;
    if ((v1 >= v2 && v1 <= v3) || (v1 <= v2 && v1 >= v3)) r.target_deflection = v1;
    else if ((v2 >= v1 && v2 <= v3) || (v2 <= v1 && v2 >= v3)) r.target_deflection = v2;
    else r.target_deflection = v3;
    *out = r;
}

bool spark_is_consensus(const command_t* c1, const command_t* c2, const command_t* c3, double tol) {
    double d12 = c1->target_deflection - c2->target_deflection;
    double d23 = c2->target_deflection - c3->target_deflection;
    double d13 = c1->target_deflection - c3->target_deflection;
    if (d12 < 0) d12 = -d12;
    if (d23 < 0) d23 = -d23;
    if (d13 < 0) d13 = -d13;
    return d12 <= tol && d23 <= tol && d13 <= tol;
}

double spark_get_current_deflection(int id) { (void)id; return 0.0; }
double spark_get_temperature(int id) { (void)id; return 25.0; }
double spark_get_hydraulic_pressure(int id) { (void)id; return 3000.0; }
channel_health_t spark_get_channel_health(int id) { (void)id; channel_health_t h = { SENSOR_OK, SENSOR_OK, SENSOR_OK, SENSOR_OK }; return h; }
int spark_get_overall_status(int id) { (void)id; return 0; }
bool spark_allocate_power(int id, double p) { (void)id; return p >= 0.0 && p <= 100.0; }
bus_load_t spark_get_bus_load(int bus) { (void)bus; bus_load_t b = { 0.0, 100.0 }; return b; }
bool spark_is_bus_overloaded(int bus) { (void)bus; return false; }
bool spark_shed_load(int bus, int id) { (void)bus; (void)id; return true; }
int spark_get_power_status(int id) { (void)id; return 0; }

actuator_state_t spark_init(limits_t limits) {
    actuator_state_t s;
    s.current_deflection = 0.0;
    s.current_mode = IDLE;
    s.last_command.target_deflection = 0.0;
    s.last_command.rate_limit = 0.0;
    s.health = HEALTHY;
    s.limit = limits;
    return s;
}

actuator_state_t spark_step(actuator_state_t state, command_t cmd) {
    state.current_deflection = cmd.target_deflection;
    state.current_mode = ACTIVE;
    state.last_command = cmd;
    return state;
}

actuator_state_t spark_fault_handler(actuator_state_t state) {
    state.current_mode = FAULT;
    state.health = FAILED;
    return state;
}

actuator_state_t spark_emergency_stop(actuator_state_t state) {
    state.current_deflection = 0.0;
    state.current_mode = EMERGENCY;
    state.last_command.target_deflection = 0.0;
    state.last_command.rate_limit = 0.0;
    return state;
}

bool spark_is_safe(actuator_state_t state) {
    return state.current_mode != FAULT && state.current_mode != EMERGENCY && state.health == HEALTHY;
}
