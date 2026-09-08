open Trajectory_types
open Optimizer
open Setpoint_gen
open Mode_manager

let create_trajectory (start : state) (targets : waypoint list) (params : trajectory_parameters) : trajectory =
  compute_trajectory start targets params

let generate_actuator_commands (traj : trajectory) (control_freq : float) (rate_limits : float list) : actuator_command list =
  generate_commands traj control_freq rate_limits

let optimize_and_convert (start : state) (targets : waypoint list) (params : trajectory_parameters) (control_freq : float) (rate_limits : float list) : actuator_command list =
  let traj = compute_trajectory start targets params in
  generate_commands traj control_freq rate_limits

let validate_trajectory (traj : trajectory) : bool =
  let rec check_waypoints ws =
    match ws with
    | [] -> true
    | w :: rest ->
        if w.time_to_reach <= 0.0 then false
        else check_waypoints rest
  in
  traj.duration >= 0.0 && check_waypoints traj.waypoints

let get_duration (traj : trajectory) : float =
  traj.duration

let get_waypoints (traj : trajectory) : waypoint list =
  traj.waypoints

let get_start_state (traj : trajectory) : state =
  traj.start_state
