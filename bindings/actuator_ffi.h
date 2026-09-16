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

typedef enum {
    HEALTHY = 0,
    DEGRADED = 1,
    FAILED = 2
} health_status_t;

bool validate_command(double current, double target, double max_rate, double max_def, double min_def);
command_t apply_limits(command_t cmd, limits_t limits);
bool is_within_limits(double value, limits_t limits);
health_status_t check_overall_status(uint8_t pos_status, uint8_t temp_status, uint8_t curr_status, uint8_t hyd_status);
command_t majority_vote(command_t c1, command_t c2, command_t c3, limits_t limits);
bool is_consensus(command_t c1, command_t c2, command_t c3, double tolerance);

#endif
