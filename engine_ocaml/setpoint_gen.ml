open Trajectory_types

let interpolate_linear (t0 : float) (t1 : float) (v0 : float) (v1 : float) (t : float) : float =
  let ratio = (t -. t0) /. (t1 -. t0) in
  v0 +. ratio *. (v1 -. v0)

let generate_setpoints (traj : trajectory) (control_freq : float) : (float * float) list =
  let dt = 1.0 /. control_freq in
  let rec loop remaining_waypoints current_time current_pos current_vel acc =
    match remaining_waypoints with
    | [] -> List.rev acc
    | w :: rest ->
        let segment_end = current_time +. w.time_to_reach in
        let rec segment_loop t acc_inner =
          if t >= segment_end then
            let final_pos = w.target_position in
            let final_vel = w.target_velocity in
            let new_acc = (final_pos, final_vel) :: acc_inner in
            loop rest segment_end final_pos final_vel new_acc
          else
            let pos = interpolate_linear current_time segment_end current_pos w.target_position t in
            let vel = interpolate_linear current_time segment_end current_vel w.target_velocity t in
            segment_loop (t +. dt) ((pos, vel) :: acc_inner)
        in
        segment_loop current_time acc
  in
  match traj.waypoints with
  | [] -> []
  | first :: rest ->
      let initial_pos = traj.start_state.position in
      let initial_vel = traj.start_state.velocity in
      let start_time = traj.start_state.timestamp in
      let first_segment_end = start_time +. first.time_to_reach in
      let rec first_segment_loop t acc =
        if t >= first_segment_end then
          let final_pos = first.target_position in
          let final_vel = first.target_velocity in
          let new_acc = (final_pos, final_vel) :: acc in
          loop rest first_segment_end final_pos final_vel new_acc
        else
          let pos = interpolate_linear start_time first_segment_end initial_pos first.target_position t in
          let vel = interpolate_linear start_time first_segment_end initial_vel first.target_velocity t in
          first_segment_loop (t +. dt) ((pos, vel) :: acc)
      in
      List.rev (first_segment_loop start_time [])

let to_actuator_commands (setpoints : (float * float) list) (rate_limits : float list) : actuator_command list =
  let rec zip_with_rate sp rates acc =
    match sp, rates with
    | [], _ -> List.rev acc
    | _, [] -> List.rev acc
    | (pos, vel) :: rest_sp, rate :: rest_rate ->
        let cmd = { deflection = pos; rate_limit = rate } in
        zip_with_rate rest_sp rest_rate (cmd :: acc)
  in
  let default_rates = List.map (fun _ -> 0.1) setpoints in
  zip_with_rate setpoints (if List.length rate_limits = List.length setpoints then rate_limits else default_rates) []

let generate_commands (traj : trajectory) (control_freq : float) (rate_limits : float list) : actuator_command list =
  let setpoints = generate_setpoints traj control_freq in
  to_actuator_commands setpoints rate_limits
