open Trajectory_types

let interpolate_linear t0 t1 v0 v1 t =
  let ratio = (t -. t0) /. (t1 -. t0) in
  v0 +. ratio *. (v1 -. v0)

let total_steps (traj : trajectory) (dt : float) : int =
  let total_time = List.fold_left (fun acc w -> acc +. w.time_to_reach) 0.0 traj.waypoints in
  let n = int_of_float (total_time /. dt) + 1 in
  if n < 0 then 0 else n

let generate_setpoints (traj : trajectory) (control_freq : float) : (float * float) list =
  let dt = 1.0 /. control_freq in
  let n_steps = total_steps traj dt in
  let buffer : (float * float) array = Array.make (max n_steps 1) (0.0, 0.0) in
  let idx = ref 0 in
  let cur_time = ref traj.start_state.timestamp in
  let cur_pos = ref traj.start_state.position in
  let cur_vel = ref traj.start_state.velocity in
  List.iter (fun w ->
    let seg_end = !cur_time +. w.time_to_reach in
    let seg_start_t = !cur_time in
    let seg_start_pos = !cur_pos in
    let seg_start_vel = !cur_vel in
    let t = ref seg_start_t in
    while !t < seg_end && !idx < Array.length buffer do
      let pos = interpolate_linear seg_start_t seg_end seg_start_pos w.target_position !t in
      let vel = interpolate_linear seg_start_t seg_end seg_start_vel w.target_velocity !t in
      buffer.(!idx) <- (pos, vel);
      incr idx;
      t := !t +. dt
    done;
    if !idx < Array.length buffer then begin
      buffer.(!idx) <- (w.target_position, w.target_velocity);
      incr idx
    end;
    cur_time := seg_end;
    cur_pos := w.target_position;
    cur_vel := w.target_velocity
  ) traj.waypoints;
  Array.sub buffer 0 !idx |> Array.to_list

let to_actuator_commands (setpoints : (float * float) list) (rate_limits : float list) : actuator_command list =
  let has_matching_rates = List.length rate_limits = List.length setpoints in
  if has_matching_rates then
    List.map2 (fun (pos, _) rate -> { deflection = pos; rate_limit = rate }) setpoints rate_limits
  else
    List.map (fun (pos, _) -> { deflection = pos; rate_limit = 0.1 }) setpoints

let generate_commands (traj : trajectory) (control_freq : float) (rate_limits : float list) : actuator_command list =
  let setpoints = generate_setpoints traj control_freq in
  to_actuator_commands setpoints rate_limits
