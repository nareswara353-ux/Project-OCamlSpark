open Trajectory_types
open Serializer

let test_state_roundtrip () =
  let s = { position = 1.5; velocity = 0.3; acceleration = 0.1; timestamp = 5.0 } in
  let encoded = serialize_state s in
  match deserialize_state encoded with
  | Ok parsed ->
      Alcotest.(check (float 0.0001)) "pos" s.position parsed.position;
      Alcotest.(check (float 0.0001)) "vel" s.velocity parsed.velocity;
      Alcotest.(check (float 0.0001)) "ts" s.timestamp parsed.timestamp
  | Error e -> Alcotest.fail ("roundtrip failed: " ^ Error.to_string e)

let test_state_bad_format () =
  match deserialize_state "1.0|2.0" with
  | Ok _ -> Alcotest.fail "expected error"
  | Error _ -> Alcotest.(check bool) "rejected" true true

let test_command_roundtrip () =
  let c = { deflection = 0.75; rate_limit = 0.15 } in
  let encoded = serialize_command c in
  match deserialize_command encoded with
  | Ok parsed ->
      Alcotest.(check (float 0.0001)) "deflection" c.deflection parsed.deflection;
      Alcotest.(check (float 0.0001)) "rate" c.rate_limit parsed.rate_limit
  | Error e -> Alcotest.fail ("roundtrip failed: " ^ Error.to_string e)

let test_command_bad_format () =
  match deserialize_command "0.5" with
  | Ok _ -> Alcotest.fail "expected error"
  | Error _ -> Alcotest.(check bool) "rejected" true true

let test_trajectory_roundtrip () =
  let start = { position = 0.0; velocity = 0.0; acceleration = 0.0; timestamp = 0.0 } in
  let wps = [
    { target_position = 0.5; target_velocity = 0.3; time_to_reach = 1.0 };
    { target_position = 0.8; target_velocity = 0.0; time_to_reach = 1.5 }
  ] in
  let traj = { waypoints = wps; start_state = start; duration = 2.5 } in
  let encoded = serialize_trajectory traj in
  match deserialize_trajectory encoded with
  | Ok parsed ->
      Alcotest.(check (float 0.0001)) "duration" traj.duration parsed.duration;
      Alcotest.(check int) "waypoint count" 2 (List.length parsed.waypoints)
  | Error e -> Alcotest.fail ("roundtrip failed: " ^ Error.to_string e)

let test_command_list_roundtrip () =
  let cmds = [
    { deflection = 0.1; rate_limit = 0.1 };
    { deflection = 0.2; rate_limit = 0.2 };
    { deflection = 0.3; rate_limit = 0.3 }
  ] in
  let encoded = serialize_command_list cmds in
  match deserialize_command_list encoded with
  | Ok parsed ->
      Alcotest.(check int) "count" 3 (List.length parsed);
      let first = List.hd parsed in
      Alcotest.(check (float 0.0001)) "first deflection" 0.1 first.deflection
  | Error e -> Alcotest.fail ("roundtrip failed: " ^ Error.to_string e)

let () =
  Alcotest.run "Serializer" [
    "state_rt", [ Alcotest.test_case "roundtrip" `Quick test_state_roundtrip ];
    "state_bad", [ Alcotest.test_case "bad format" `Quick test_state_bad_format ];
    "cmd_rt", [ Alcotest.test_case "roundtrip" `Quick test_command_roundtrip ];
    "cmd_bad", [ Alcotest.test_case "bad format" `Quick test_command_bad_format ];
    "traj_rt", [ Alcotest.test_case "roundtrip" `Quick test_trajectory_roundtrip ];
    "list_rt", [ Alcotest.test_case "command list" `Quick test_command_list_roundtrip ];
  ]
