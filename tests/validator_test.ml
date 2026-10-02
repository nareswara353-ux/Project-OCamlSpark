open Trajectory_types
open Validator

let test_valid_waypoint () =
  let wp = { target_position = 0.5; target_velocity = 0.3; time_to_reach = 1.0 } in
  match validate_waypoint wp with
  | Ok _ -> Alcotest.(check bool) "ok" true true
  | Error e -> Alcotest.fail ("unexpected: " ^ Error.to_string e)

let test_waypoint_bad_time () =
  let wp = { target_position = 0.5; target_velocity = 0.3; time_to_reach = -1.0 } in
  match validate_waypoint wp with
  | Ok _ -> Alcotest.fail "expected error"
  | Error _ -> Alcotest.(check bool) "rejected" true true

let test_waypoint_nan () =
  let wp = { target_position = Float.nan; target_velocity = 0.0; time_to_reach = 1.0 } in
  match validate_waypoint wp with
  | Ok _ -> Alcotest.fail "expected error"
  | Error _ -> Alcotest.(check bool) "rejected" true true

let test_valid_trajectory () =
  let start = { position = 0.0; velocity = 0.0; acceleration = 0.0; timestamp = 0.0 } in
  let traj = {
    waypoints = [{ target_position = 0.5; target_velocity = 0.3; time_to_reach = 1.0 }];
    start_state = start;
    duration = 1.0
  } in
  match validate_trajectory traj with
  | Ok _ -> Alcotest.(check bool) "ok" true true
  | Error e -> Alcotest.fail ("unexpected: " ^ Error.to_string e)

let test_trajectory_negative_duration () =
  let start = { position = 0.0; velocity = 0.0; acceleration = 0.0; timestamp = 0.0 } in
  let traj = { waypoints = []; start_state = start; duration = -1.0 } in
  match validate_trajectory traj with
  | Ok _ -> Alcotest.fail "expected error"
  | Error _ -> Alcotest.(check bool) "rejected" true true

let test_valid_limits () =
  match validate_limits 0.9 (-0.9) with
  | Ok () -> Alcotest.(check bool) "ok" true true
  | Error e -> Alcotest.fail ("unexpected: " ^ Error.to_string e)

let test_inverted_limits () =
  match validate_limits 0.5 0.8 with
  | Ok () -> Alcotest.fail "expected error"
  | Error _ -> Alcotest.(check bool) "rejected" true true

let test_out_of_range_limits () =
  match validate_limits 1.5 (-0.5) with
  | Ok () -> Alcotest.fail "expected error"
  | Error _ -> Alcotest.(check bool) "rejected" true true

let test_valid_command () =
  let cmd = { deflection = 0.5; rate_limit = 0.1 } in
  match validate_command cmd 0.9 (-0.9) with
  | Ok _ -> Alcotest.(check bool) "ok" true true
  | Error e -> Alcotest.fail ("unexpected: " ^ Error.to_string e)

let test_command_out_of_range () =
  let cmd = { deflection = 1.2; rate_limit = 0.1 } in
  match validate_command cmd 0.9 (-0.9) with
  | Ok _ -> Alcotest.fail "expected error"
  | Error _ -> Alcotest.(check bool) "rejected" true true

let test_command_bad_rate () =
  let cmd = { deflection = 0.5; rate_limit = 1.5 } in
  match validate_command cmd 0.9 (-0.9) with
  | Ok _ -> Alcotest.fail "expected error"
  | Error _ -> Alcotest.(check bool) "rejected" true true

let test_valid_params () =
  let p = { max_accel = 1.0; max_velocity = 1.0; jerk_limit = 0.5 } in
  match validate_trajectory_parameters p with
  | Ok _ -> Alcotest.(check bool) "ok" true true
  | Error e -> Alcotest.fail ("unexpected: " ^ Error.to_string e)

let test_bad_params () =
  let p = { max_accel = -1.0; max_velocity = 1.0; jerk_limit = 0.5 } in
  match validate_trajectory_parameters p with
  | Ok _ -> Alcotest.fail "expected error"
  | Error _ -> Alcotest.(check bool) "rejected" true true

let () =
  Alcotest.run "Validator" [
    "waypoint_ok", [ Alcotest.test_case "valid" `Quick test_valid_waypoint ];
    "waypoint_time", [ Alcotest.test_case "negative time" `Quick test_waypoint_bad_time ];
    "waypoint_nan", [ Alcotest.test_case "NaN position" `Quick test_waypoint_nan ];
    "traj_ok", [ Alcotest.test_case "valid" `Quick test_valid_trajectory ];
    "traj_dur", [ Alcotest.test_case "negative duration" `Quick test_trajectory_negative_duration ];
    "limits_ok", [ Alcotest.test_case "valid" `Quick test_valid_limits ];
    "limits_inv", [ Alcotest.test_case "inverted" `Quick test_inverted_limits ];
    "limits_range", [ Alcotest.test_case "out of range" `Quick test_out_of_range_limits ];
    "cmd_ok", [ Alcotest.test_case "valid" `Quick test_valid_command ];
    "cmd_range", [ Alcotest.test_case "out of range" `Quick test_command_out_of_range ];
    "cmd_rate", [ Alcotest.test_case "bad rate" `Quick test_command_bad_rate ];
    "params_ok", [ Alcotest.test_case "valid" `Quick test_valid_params ];
    "params_bad", [ Alcotest.test_case "negative accel" `Quick test_bad_params ];
  ]
