open Trajectory_types
open Optimizer
open Setpoint_gen
open Mode_manager
open Actuator_binding

let test_optimizer_compute () =
  let start = { position = 0.0; velocity = 0.0; acceleration = 0.0; timestamp = 0.0 } in
  let targets = [
    { target_position = 1.0; target_velocity = 0.5; time_to_reach = 2.0 };
    { target_position = 2.0; target_velocity = 0.0; time_to_reach = 1.0 }
  ] in
  let params = { max_accel = 1.0; max_velocity = 1.0; jerk_limit = 0.5 } in
  let traj = compute_trajectory start targets params in
  let cmds = extract_commands traj in
  Alcotest.(check bool) "trajectory valid" true (traj.duration >= 0.0);
  Alcotest.(check int) "command count" 2 (List.length cmds);
  Alcotest.(check float) "first deflection" 1.0 (List.hd cmds).deflection

let test_setpoint_gen () =
  let start = { position = 0.0; velocity = 0.0; acceleration = 0.0; timestamp = 0.0 } in
  let targets = [
    { target_position = 1.0; target_velocity = 0.5; time_to_reach = 2.0 }
  ] in
  let params = { max_accel = 1.0; max_velocity = 1.0; jerk_limit = 0.5 } in
  let traj = compute_trajectory start targets params in
  let setpoints = generate_setpoints traj 10.0 in
  let cmds = to_actuator_commands setpoints [] in
  Alcotest.(check bool) "setpoints nonempty" true (List.length setpoints > 0);
  Alcotest.(check int) "commands match" (List.length setpoints) (List.length cmds)

let test_mode_manager () =
  let state = initial_mode_state in
  let mode = AutoPilot in
  let new_state = transition state mode false in
  Alcotest.(check bool) "mode transition" true (get_current_mode new_state = AutoPilot);
  let cmd = { deflection = 0.5; rate_limit = 0.5 } in
  let processed, final_state = process_command new_state cmd in
  Alcotest.(check float) "rate limited" 0.1 processed.rate_limit;
  let emergency, _ = emergency_override_command final_state 0.0 in
  Alcotest.(check float) "emergency rate" 0.01 emergency.rate_limit

let test_binding () =
  let lim = { max_deflection = 0.9; min_deflection = -0.9 } in
  let cmd = { target_deflection = 0.5; rate_limit = 0.1 } in
  let valid = validate_command 0.0 cmd.target_deflection cmd.rate_limit lim.max_deflection lim.min_deflection in
  Alcotest.(check bool) "validate command" true valid;
  let applied = apply_limits cmd lim in
  Alcotest.(check float) "apply limits" 0.5 applied.target_deflection;
  let c1 = { target_deflection = 0.4; rate_limit = 0.1 } in
  let c2 = { target_deflection = 0.5; rate_limit = 0.1 } in
  let c3 = { target_deflection = 0.6; rate_limit = 0.1 } in
  let voted = majority_vote c1 c2 c3 lim in
  Alcotest.(check float) "majority vote median" 0.5 voted.target_deflection

let () =
  let open Alcotest in
  run "Actuator Engine Tests" [
    "optimizer", [
      test_case "compute trajectory" `Quick test_optimizer_compute;
    ];
    "setpoint_gen", [
      test_case "generate setpoints" `Quick test_setpoint_gen;
    ];
    "mode_manager", [
      test_case "mode transitions" `Quick test_mode_manager;
    ];
    "binding", [
      test_case "FFI functions" `Quick test_binding;
    ];
  ]
