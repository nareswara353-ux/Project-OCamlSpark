open Trajectory_types
open Optimizer
open Setpoint_gen
open Mode_manager
open Actuator_binding

let build_sample_trajectory () =
  let start = {
    position = 0.0; velocity = 0.0; acceleration = 0.0; timestamp = 0.0;
  } in
  let targets = [
    { target_position = 0.5; target_velocity = 0.3; time_to_reach = 1.5 };
    { target_position = 0.8; target_velocity = 0.1; time_to_reach = 1.0 };
    { target_position = 0.0; target_velocity = 0.0; time_to_reach = 2.0 };
  ] in
  let params = { max_accel = 0.8; max_velocity = 0.6; jerk_limit = 0.4 } in
  compute_trajectory start targets params

let print_command index cmd =
  Printf.printf "[%03d] deflection=%.4f rate_limit=%.4f\n"
    index cmd.deflection cmd.rate_limit

let run_control_loop traj =
  let control_freq = 20.0 in
  let commands = generate_commands traj control_freq [] in
  let lim = { max_deflection = 0.95; min_deflection = -0.95 } in
  let initial_state = initial_mode_state in
  let rec loop cmds idx state =
    match cmds with
    | [] -> Printf.printf "Trajectory complete: %d commands executed\n" idx
    | cmd :: rest ->
        let bridge_cmd = {
          target_deflection = cmd.deflection;
          rate_limit = cmd.rate_limit;
        } in
        let valid =
          validate_command 0.0 bridge_cmd.target_deflection bridge_cmd.rate_limit
            lim.max_deflection lim.min_deflection
        in
        if valid then begin
          let limited = apply_limits bridge_cmd lim in
          let act_cmd = {
            deflection = limited.target_deflection;
            rate_limit = limited.rate_limit;
          } in
          let processed, new_state = process_command state act_cmd in
          print_command idx processed;
          loop rest (idx + 1) new_state
        end else begin
          Printf.printf "[%03d] INVALID command rejected: deflection=%.4f\n"
            idx cmd.deflection;
          loop rest (idx + 1) state
        end
  in
  Printf.printf "Trajectory duration: %.4f seconds\n" traj.duration;
  Printf.printf "Total waypoints: %d\n" (List.length traj.waypoints);
  Printf.printf "Control frequency: %.1f Hz\n" control_freq;
  Printf.printf "Beginning control loop execution\n";
  loop commands 0 initial_state

let demonstrate_voter () =
  let lim = { max_deflection = 0.95; min_deflection = -0.95 } in
  let c1 = { target_deflection = 0.4; rate_limit = 0.1 } in
  let c2 = { target_deflection = 0.5; rate_limit = 0.1 } in
  let c3 = { target_deflection = 0.6; rate_limit = 0.1 } in
  let voted = majority_vote c1 c2 c3 lim in
  let consensus = is_consensus c1 c2 c3 0.25 in
  Printf.printf "Voter result: %.4f\n" voted.target_deflection;
  Printf.printf "Consensus detected: %b\n" consensus

let () =
  Printf.printf "Flight Control Surface Actuator Controller\n";
  Printf.printf "Hybrid OCaml + SPARK High-Assurance System\n";
  let traj = build_sample_trajectory () in
  demonstrate_voter ();
  run_control_loop traj
