#ifndef OCAML_GLUE_H
#define OCAML_GLUE_H

#include "spark_export.h"
#include <stddef.h>

typedef struct {
    float position;
    float velocity;
} setpoint_t;

typedef struct {
    setpoint_t* points;
    size_t count;
    float duration;
    float max_rate;
} trajectory_data_t;

typedef struct {
    float target_deflection;
    float rate_limit;
} actuator_cmd_t;

typedef enum {
    GLUE_MANUAL = 0,
    GLUE_AUTOPILOT = 1,
    GLUE_EMERGENCY = 2
} glue_flight_mode_t;

actuator_cmd_t glue_send_trajectory_point(setpoint_t point, float max_rate);
actuator_cmd_t glue_finalize_trajectory(trajectory_data_t trajectory);
void glue_abort_trajectory(void);
bool glue_is_trajectory_active(void);
glue_flight_mode_t glue_get_current_mode(void);
void glue_set_mode(glue_flight_mode_t mode);
actuator_cmd_t glue_get_emergency_command(float deflection);
float glue_get_min_deflection(void);
float glue_get_max_deflection(void);
bool glue_validate_external_command(float deflection, float rate);

#endif
