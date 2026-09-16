#include "actuator_ffi.h"

extern bool   spark_validate_command(double, double, double, double, double);
extern void   spark_apply_limits(const command_t*, const limits_t*, command_t*);
extern bool   spark_is_within_limits(double, const limits_t*);
extern int    spark_check_overall_status(int, int, int, int);
extern void   spark_majority_vote(const command_t*, const command_t*, const command_t*, const limits_t*, command_t*);
extern bool   spark_is_consensus(const command_t*, const command_t*, const command_t*, double);

void ocaml_force_link(void) { }

bool validate_command(double current, double target, double max_rate, double max_def, double min_def) {
    return spark_validate_command(current, target, max_rate, max_def, min_def);
}

void apply_limits(const command_t* cmd, const limits_t* limits, command_t* out) {
    spark_apply_limits(cmd, limits, out);
}

bool is_within_limits(double value, const limits_t* limits) {
    return spark_is_within_limits(value, limits);
}

health_status_t check_overall_status(int pos_status, int temp_status, int curr_status, int hyd_status) {
    int r = spark_check_overall_status(pos_status, temp_status, curr_status, hyd_status);
    if (r == 0) return HEALTHY;
    if (r == 1) return DEGRADED;
    return FAILED;
}

void majority_vote(const command_t* c1, const command_t* c2, const command_t* c3, const limits_t* limits, command_t* out) {
    spark_majority_vote(c1, c2, c3, limits, out);
}

bool is_consensus(const command_t* c1, const command_t* c2, const command_t* c3, double tolerance) {
    return spark_is_consensus(c1, c2, c3, tolerance);
}
