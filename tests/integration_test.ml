open Trajectory_types
open Optimizer
open Setpoint_gen
open Mode_manager
open Actuator_binding

let test_full_flow () =
  let start = { position = 0.0; velocity = 0.0; acceleration = 0.0; timestamp = 0.0 } in
  let targets = [
    { target_position = 1.0; target_velocity = 0.5; time_to_reach = 2.0 };
    { target_position = 2.0; target_velocity = 0.0; time_to_reach = 1.0 }
  ] in
  let params = { max_accel = 1.0; max_velocity = 1.0; jerk_limit = 0.5 } in
  let traj = compute_trajectory start targets params in
  let cmds = generate_commands traj 10.0 [] in
  let lim = { max_deflection = 0.95; min_deflection = -0.95 } in
  let first_cmd = List.hd cmds in
  let valid = validate_command 0.0 first_cmd.deflection first_cmd.rate_limit lim.max_deflection lim.min_deflection in
  Alcotest.(check bool) "FFI validation passes" true valid;
  let applied = apply_limits first_cmd lim in
  Alcotest.(check float) "limits applied" first_cmd.deflection applied.target_deflection

let test_redundancy_integration () =
  let lim = { max_deflection = 0.9; min_deflection = -0.9 } in
  let c1 = { target_deflection = 0.4; rate_limit = 0.1 } in
  let c2 = { target_deflection = 0.5; rate_limit = 0.1 } in
  let c3 = { target_deflection = 0.6; rate_limit = 0.1 } in
  let voted = majority_vote c1 c2 c3 lim in
  Alcotest.(check float) "voted median" 0.5 voted.target_deflection;
  let consensus = is_consensus c1 c2 c3 0.2 in
  Alcotest.(check bool) "consensus within tolerance" true consensus

let test_emergency_integration () =
  let start = { position = 0.0; velocity = 0.0; acceleration = 0.0; timestamp = 0.0 } in
  let targets = [
    { target_position = 1.0; target_velocity = 0.5; time_to_reach = 2.0 }
  ] in
  let params = { max_accel = 1.0; max_velocity = 1.0; jerk_limit = 0.5 } in
  let traj = compute_trajectory start targets params in
  let cmds = generate_commands traj 10.0 [] in
  let state = initial_mode_state in
  let _, state_after = process_command state (List.hd cmds) in
  let emergency_cmd, _ = emergency_override_command state_after 0.0 in
  Alcotest.(check float) "emergency rate" 0.01 emergency_cmd.rate_limit;
  Alcotest.(check float) "emergency deflection" 0.0 emergency_cmd.deflection

let () =
  let open Alcotest in
  run "Integration Tests" [
    "full_flow", [
      test_case "complete trajectory to command" `Quick test_full_flow;
    ];
    "redundancy", [
      test_case "voter and consensus" `Quick test_redundancy_integration;
    ];
    "emergency", [
      test_case "emergency override" `Quick test_emergency_integration;
    ];
  ]
