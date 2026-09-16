#ifndef ACTUATOR_FFI_H
#define ACTUATOR_FFI_H

#include <stdint.h>
#include <stdbool.h>

typedef double deflection_t;

typedef struct {
    deflection_t target_deflection;
    double rate_limit;
} command_t;

typedef struct {
    deflection_t max_deflection;
    deflection_t min_deflection;
} limits_t;

typedef enum { HEALTHY = 0, DEGRADED = 1, FAILED = 2 } health_status_t;

bool validate_command(double current, double target, double max_rate, double max_def, double min_def);
void apply_limits(const command_t* cmd, const limits_t* limits, command_t* out);
bool is_within_limits(double value, const limits_t* limits);
health_status_t check_overall_status(int pos_status, int temp_status, int curr_status, int hyd_status);
void majority_vote(const command_t* c1, const command_t* c2, const command_t* c3, const limits_t* limits, command_t* out);
bool is_consensus(const command_t* c1, const command_t* c2, const command_t* c3, double tolerance);

#endif
