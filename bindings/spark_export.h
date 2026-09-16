#ifndef SPARK_EXPORT_H
#define SPARK_EXPORT_H

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
typedef enum { IDLE = 0, ACTIVE = 1, FAULT = 2, EMERGENCY = 3 } controller_state_t;

typedef struct {
    deflection_t current_deflection;
    controller_state_t current_mode;
    command_t last_command;
    health_status_t health;
    limits_t limit;
} actuator_state_t;

typedef enum { SENSOR_OK = 0, SENSOR_WARNING = 1, SENSOR_CRITICAL = 2 } sensor_health_t;

typedef struct {
    sensor_health_t position;
    sensor_health_t temperature;
    sensor_health_t current;
    sensor_health_t hydraulic;
} channel_health_t;

typedef enum { LOAD_NORMAL = 0, LOAD_OVERLOADED = 1, LOAD_CRITICAL = 2 } load_status_t;

typedef struct {
    double current_load;
    double max_capacity;
} bus_load_t;

typedef enum { BUS_A = 0, BUS_B = 1, EMERGENCY_BUS = 2 } power_bus_t;

bool spark_validate_command(double current, double target, double max_rate, double max_def, double min_def);
void spark_apply_limits(const command_t* cmd, const limits_t* limits, command_t* out);
bool spark_is_within_limits(double value, const limits_t* limits);
int  spark_check_overall_status(int pos, int temp, int curr, int hyd);
void spark_majority_vote(const command_t* c1, const command_t* c2, const command_t* c3, const limits_t* limits, command_t* out);
bool spark_is_consensus(const command_t* c1, const command_t* c2, const command_t* c3, double tolerance);
double spark_get_current_deflection(int id);
double spark_get_temperature(int id);
double spark_get_hydraulic_pressure(int id);
channel_health_t spark_get_channel_health(int id);
int spark_get_overall_status(int id);
bool spark_allocate_power(int id, double required_power);
bus_load_t spark_get_bus_load(int bus);
bool spark_is_bus_overloaded(int bus);
bool spark_shed_load(int bus, int id);
int spark_get_power_status(int id);
actuator_state_t spark_init(limits_t limits);
actuator_state_t spark_step(actuator_state_t state, command_t cmd);
actuator_state_t spark_fault_handler(actuator_state_t state);
actuator_state_t spark_emergency_stop(actuator_state_t state);
bool spark_is_safe(actuator_state_t state);

#endif
