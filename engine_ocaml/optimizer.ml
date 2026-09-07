open Trajectory_types

let compute_velocity (w1 : waypoint) (w2 : waypoint) (dt : float) : float =
  (w2.target_position -. w1.target_position) /. dt

let clamp_velocity v max_v =
  if v > max_v then max_v
  else if v < -.max_v then -.max_v
  else v

let clamp_accel a max_a =
  if a > max_a then max_a
  else if a < -.max_a then -.max_a
  else a

let generate_waypoints (start : state) (targets : waypoint list) (params : trajectory_parameters) : waypoint list =
  let rec loop prev targets acc =
    match targets with
    | [] -> List.rev acc
    | w :: rest ->
        let dt = w.time_to_reach in
        let raw_v = compute_velocity prev w dt in
        let clamped_v = clamp_velocity raw_v params.max_velocity in
        let accel = (clamped_v -. prev.velocity) /. dt in
        let clamped_accel = clamp_accel accel params.max_accel in
        let adjusted_v = prev.velocity +. clamped_accel *. dt in
        let adjusted_pos = prev.position +. adjusted_v *. dt in
        let new_w = { target_position = adjusted_pos; target_velocity = adjusted_v; time_to_reach = dt } in
        let new_state = { position = adjusted_pos; velocity = adjusted_v; acceleration = clamped_accel; timestamp = prev.timestamp +. dt } in
        loop new_state rest (new_w :: acc)
  in
  match targets with
  | [] -> []
  | first :: _ ->
      let dt = first.time_to_reach in
      let raw_v = compute_velocity start first dt in
      let clamped_v = clamp_velocity raw_v params.max_velocity in
      let accel = (clamped_v -. start.velocity) /. dt in
      let clamped_accel = clamp_accel accel params.max_accel in
      let adjusted_v = start.velocity +. clamped_accel *. dt in
      let adjusted_pos = start.position +. adjusted_v *. dt in
      let new_w = { target_position = adjusted_pos; target_velocity = adjusted_v; time_to_reach = dt } in
      let new_state = { position = adjusted_pos; velocity = adjusted_v; acceleration = clamped_accel; timestamp = start.timestamp +. dt } in
      loop new_state (List.tl targets) [new_w]

let compute_trajectory (start : state) (targets : waypoint list) (params : trajectory_parameters) : trajectory =
  let waypoints = generate_waypoints start targets params in
  let duration = List.fold_left (fun acc w -> acc +. w.time_to_reach) 0.0 waypoints in
  { waypoints; start_state = start; duration }

let extract_commands (traj : trajectory) : actuator_command list =
  List.map (fun w -> { deflection = w.target_position; rate_limit = 0.1 }) traj.waypoints
