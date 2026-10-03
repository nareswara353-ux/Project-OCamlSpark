open Trajectory_types
open Optimizer
open Setpoint_gen
open Logger

let () =
  let log = Logger.create ~min_level:Debug () in
  Logger.info log "example" "Building simple trajectory" [];

  let start = { position = 0.0; velocity = 0.0; acceleration = 0.0; timestamp = 0.0 } in
  let targets = [
    { target_position = 0.3; target_velocity = 0.2; time_to_reach = 1.0 };
    { target_position = 0.6; target_velocity = 0.0; time_to_reach = 1.5 };
    { target_position = 0.0; target_velocity = 0.0; time_to_reach = 2.0 };
  ] in
  let params = { max_accel = 0.5; max_velocity = 0.4; jerk_limit = 0.3 } in

  let traj = compute_trajectory start targets params in
  Logger.info log "example"
    (Printf.sprintf "Trajectory duration: %.3f s" traj.duration) [];

  let cmds = generate_commands traj 10.0 [] in
  Logger.info log "example"
    (Printf.sprintf "Generated %d commands" (List.length cmds)) [];

  List.iteri (fun i cmd ->
    if i mod 10 = 0 then
      Logger.debug log "example"
        (Printf.sprintf "[%03d] deflection=%.4f" i cmd.deflection) []
  ) cmds;

  Logger.info log "example" "Done" []
