let test_version_string () =
  Alcotest.(check bool) "non-empty" true (String.length Version.version_string > 0)

let test_version_components () =
  Alcotest.(check int) "major" 0 Version.version_major;
  Alcotest.(check int) "minor" 1 Version.version_minor;
  Alcotest.(check int) "patch" 0 Version.version_patch

let test_build_info () =
  let info = Version.build_info () in
  Alcotest.(check bool) "has entries" true (List.length info >= 5);
  let keys = List.map fst info in
  Alcotest.(check bool) "has name" true (List.mem "name" keys);
  Alcotest.(check bool) "has version" true (List.mem "version" keys);
  Alcotest.(check bool) "has safety_kernel" true (List.mem "safety_kernel" keys)

let test_banner () =
  let b = Version.banner () in
  Alcotest.(check bool) "banner non-empty" true (String.length b > 0);
  Alcotest.(check bool) "contains version" true
    (try ignore (Str.search_forward (Str.regexp_string Version.version_string) b 0); true
     with Not_found -> false)

let test_build_timestamp () =
  let t = Version.build_timestamp () in
  Alcotest.(check bool) "positive" true (t > 0.0)

let test_simple_trajectory_flow () =
  let open Trajectory_types in
  let open Optimizer in
  let open Setpoint_gen in
  let start = { position = 0.0; velocity = 0.0; acceleration = 0.0; timestamp = 0.0 } in
  let targets = [
    { target_position = 0.3; target_velocity = 0.2; time_to_reach = 1.0 };
    { target_position = 0.6; target_velocity = 0.0; time_to_reach = 1.5 };
  ] in
  let params = { max_accel = 0.5; max_velocity = 0.4; jerk_limit = 0.3 } in
  let traj = compute_trajectory start targets params in
  let cmds = generate_commands traj 10.0 [] in
  Alcotest.(check bool) "commands generated" true (List.length cmds > 0);
  Alcotest.(check bool) "trajectory duration positive" true (traj.duration > 0.0)

let test_emergency_flow () =
  let open Trajectory_types in
  let open Mode_manager in
  let state = initial_mode_state in
  let cmd = { deflection = 0.5; rate_limit = 0.1 } in
  let state_auto = transition state AutoPilot false in
  let _, _ = process_command state_auto cmd in
  let emergency_cmd, state_emerg = emergency_override_command state_auto 0.0 in
  Alcotest.(check (float 0.001)) "emergency rate" 0.01 emergency_cmd.rate_limit;
  Alcotest.(check bool) "emergency active" true (is_emergency_active state_emerg)

let () =
  Alcotest.run "Examples_smoke" [
    "version_string", [ Alcotest.test_case "non-empty" `Quick test_version_string ];
    "version_components", [ Alcotest.test_case "components" `Quick test_version_components ];
    "build_info", [ Alcotest.test_case "metadata" `Quick test_build_info ];
    "banner", [ Alcotest.test_case "formatted" `Quick test_banner ];
    "timestamp", [ Alcotest.test_case "positive" `Quick test_build_timestamp ];
    "trajectory_flow", [ Alcotest.test_case "end-to-end" `Quick test_simple_trajectory_flow ];
    "emergency_flow", [ Alcotest.test_case "override" `Quick test_emergency_flow ];
  ]
