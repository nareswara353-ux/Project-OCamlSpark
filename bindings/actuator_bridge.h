#ifndef ACTUATOR_BRIDGE_H
#define ACTUATOR_BRIDGE_H

#include "spark_export.h"
#include <stdint.h>

typedef struct {
    double position;
    double velocity;
    double acceleration;
    double timestamp;
} ocaml_state_t;

typedef struct {
    double target_position;
    double target_velocity;
    double time_to_reach;
} ocaml_waypoint_t;

typedef struct {
    ocaml_waypoint_t* waypoints;
    int waypoint_count;
    ocaml_state_t start_state;
    double duration;
} ocaml_trajectory_t;

typedef struct {
    double deflection;
    double rate_limit;
} ocaml_command_t;

typedef enum {
    OCAML_MANUAL = 0,
    OCAML_AUTOPILOT = 1,
    OCAML_EMERGENCY = 2
} ocaml_flight_mode_t;

typedef struct {
    double max_accel;
    double max_velocity;
    double jerk_limit;
} ocaml_traj_params_t;

command_t bridge_command_to_spark(ocaml_command_t cmd);
limits_t bridge_limits_to_spark(double max_def, double min_def);
actuator_state_t bridge_state_to_spark(ocaml_state_t state);
ocaml_state_t bridge_state_from_spark(actuator_state_t state);
ocaml_command_t bridge_command_from_spark(command_t cmd);
bool bridge_validate_ocaml_command(ocaml_command_t cmd, double max_def, double min_def);
ocaml_command_t bridge_apply_ocaml_limits(ocaml_command_t cmd, double max_def, double min_def);
ocaml_command_t bridge_majority_vote_ocaml(ocaml_command_t c1, ocaml_command_t c2, ocaml_command_t c3, double max_def, double min_def);
bool bridge_is_consensus_ocaml(ocaml_command_t c1, ocaml_command_t c2, ocaml_command_t c3, double tolerance);
void bridge_log_command(ocaml_command_t cmd);
void bridge_log_state(ocaml_state_t state);

#endif
