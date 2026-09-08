#ifndef SPARK_EXPORT_H
#define SPARK_EXPORT_H

#include <stdint.h>
#include <stdbool.h>

typedef float deflection_t;

typedef struct {
    deflection_t target_deflection;
    float rate_limit;
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

typedef enum {
    IDLE = 0,
    ACTIVE = 1,
    FAULT = 2,
    EMERGENCY = 3
} controller_state_t;

typedef struct {
    deflection_t current_deflection;
    controller_state_t current_mode;
    command_t last_command;
    health_status_t health;
    limits_t limit;
} actuator_state_t;

typedef enum {
    OK = 0,
    WARNING = 1,
    CRITICAL = 2
} sensor_health_t;

typedef struct {
    sensor_health_t position;
    sensor_health_t temperature;
    sensor_health_t current;
    sensor_health_t hydraulic;
} channel_health_t;

typedef enum {
    NORMAL = 0,
    OVERLOADED = 1,
    CRITICAL = 2
} load_status_t;

typedef struct {
    float current_load;
    float max_capacity;
} bus_load_t;

typedef enum {
    BUS_A = 0,
    BUS_B = 1,
    EMERGENCY_BUS = 2
} power_bus_t;

bool spark_validate_command(float current, float target, float max_rate, float max_def, float min_def);
command_t spark_apply_limits(command_t cmd, limits_t limits);
bool spark_is_within_limits(float value, limits_t limits);
health_status_t spark_check_overall_status(uint8_t pos_status, uint8_t temp_status, uint8_t curr_status, uint8_t hyd_status);
command_t spark_majority_vote(command_t c1, command_t c2, command_t c3, limits_t limits);
bool spark_is_consensus(command_t c1, command_t c2, command_t c3, float tolerance);
deflection_t spark_get_current_deflection(uint8_t id);
float spark_get_temperature(uint8_t id);
float spark_get_hydraulic_pressure(uint8_t id);
channel_health_t spark_get_channel_health(uint8_t id);
health_status_t spark_get_overall_status(uint8_t id);
bool spark_allocate_power(uint8_t id, float required_power);
bus_load_t spark_get_bus_load(uint8_t bus);
bool spark_is_bus_overloaded(uint8_t bus);
bool spark_shed_load(uint8_t bus, uint8_t id);
load_status_t spark_get_power_status(uint8_t id);
actuator_state_t spark_init(limits_t limits);
actuator_state_t spark_step(actuator_state_t state, command_t cmd);
actuator_state_t spark_fault_handler(actuator_state_t state);
actuator_state_t spark_emergency_stop(actuator_state_t state);
bool spark_is_safe(actuator_state_t state);

#endif
