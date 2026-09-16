open Trajectory_types

let compute_velocity (w1 : waypoint) (w2 : waypoint) (dt : float) : float =
  if dt <= 0.0 then 0.0
  else (w2.target_position -. w1.target_position) /. dt

let clamp_velocity v max_v =
  if v > max_v then max_v
  else if v < -.max_v then -.max_v
  else v

let clamp_accel a max_a =
  if a > max_a then max_a
  else if a < -.max_a then -.max_a
  else a

let state_to_waypoint (s : state) : waypoint =
  { target_position = s.position;
    target_velocity = s.velocity;
    time_to_reach = 0.0 }

let generate_waypoints
    (start : state)
    (targets : waypoint list)
    (params : trajectory_parameters) : waypoint list =
  let start_wp = state_to_waypoint start in
  let rec loop (prev : waypoint) (remaining : waypoint list) (acc : waypoint list) =
    match remaining with
    | [] -> List.rev acc
    | w :: rest ->
        let dt = if w.time_to_reach <= 0.0 then 0.001 else w.time_to_reach in
        let raw_v = compute_velocity prev w dt in
        let clamped_v = clamp_velocity raw_v params.max_velocity in
        let accel = (clamped_v -. prev.target_velocity) /. dt in
        let clamped_accel = clamp_accel accel params.max_accel in
        let adjusted_v = prev.target_velocity +. clamped_accel *. dt in
        let adjusted_pos = prev.target_position +. adjusted_v *. dt in
        let new_w = { target_position = adjusted_pos;
                      target_velocity = adjusted_v;
                      time_to_reach = dt } in
        loop new_w rest (new_w :: acc)
  in
  loop start_wp targets []

let compute_trajectory
    (start : state)
    (targets : waypoint list)
    (params : trajectory_parameters) : trajectory =
  let waypoints = generate_waypoints start targets params in
  let duration = List.fold_left (fun acc w -> acc +. w.time_to_reach) 0.0 waypoints in
  { waypoints; start_state = start; duration }

let extract_commands (traj : trajectory) : actuator_command list =
  List.map
    (fun w -> { deflection = w.target_position; rate_limit = 0.1 })
    traj.waypoints
