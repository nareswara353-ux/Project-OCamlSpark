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
    SENSOR_OK = 0,
    SENSOR_WARNING = 1,
    SENSOR_CRITICAL = 2
} sensor_health_t;

typedef struct {
    sensor_health_t position;
    sensor_health_t temperature;
    sensor_health_t current;
    sensor_health_t hydraulic;
} channel_health_t;

typedef enum {
    LOAD_NORMAL = 0,
    LOAD_OVERLOADED = 1,
    LOAD_CRITICAL = 2
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
int  spark_check_overall_status(int pos, int temp, int curr, int hyd);
command_t spark_majority_vote(command_t c1, command_t c2, command_t c3, limits_t limits);
bool spark_is_consensus(command_t c1, command_t c2, command_t c3, float tolerance);
float spark_get_current_deflection(int id);
float spark_get_temperature(int id);
float spark_get_hydraulic_pressure(int id);
channel_health_t spark_get_channel_health(int id);
int spark_get_overall_status(int id);
bool spark_allocate_power(int id, float required_power);
bus_load_t spark_get_bus_load(int bus);
bool spark_is_bus_overloaded(int bus);
bool spark_shed_load(int bus, int id);
int spark_get_power_status(int id);

#endif
