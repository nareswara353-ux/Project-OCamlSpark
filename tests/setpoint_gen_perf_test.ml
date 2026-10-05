open Trajectory_types
open Setpoint_gen

let mk_traj waypoints =
  let start = { position = 0.0; velocity = 0.0; acceleration = 0.0; timestamp = 0.0 } in
  let duration = List.fold_left (fun acc w -> acc +. w.time_to_reach) 0.0 waypoints in
  { waypoints; start_state = start; duration }

let test_empty_trajectory () =
  let traj = mk_traj [] in
  let sps = generate_setpoints traj 20.0 in
  Alcotest.(check int) "empty" 0 (List.length sps)

let test_single_waypoint () =
  let traj = mk_traj [
    { target_position = 0.5; target_velocity = 0.0; time_to_reach = 1.0 }
  ] in
  let sps = generate_setpoints traj 10.0 in
  Alcotest.(check bool) "non-empty" true (List.length sps > 0);
  let last = List.nth sps (List.length sps - 1) in
  Alcotest.(check (float 0.01)) "last pos" 0.5 (fst last)

let test_ordering () =
  let traj = mk_traj [
    { target_position = 0.3; target_velocity = 0.0; time_to_reach = 0.5 };
    { target_position = 0.7; target_velocity = 0.0; time_to_reach = 0.5 };
  ] in
  let sps = generate_setpoints traj 20.0 in
  let positions = List.map fst sps in
  let rec monotonic = function
    | a :: (b :: _ as rest) -> a <= b && monotonic rest
    | _ -> true
  in
  Alcotest.(check bool) "non-decreasing" true (monotonic positions)

let test_step_count () =
  let traj = mk_traj [
    { target_position = 1.0; target_velocity = 0.0; time_to_reach = 1.0 }
  ] in
  let sps_10 = generate_setpoints traj 10.0 in
  let sps_100 = generate_setpoints traj 100.0 in
  Alcotest.(check bool) "100Hz lebih banyak dari 10Hz" true
    (List.length sps_100 > List.length sps_10)

let test_commands_with_rates () =
  let traj = mk_traj [
    { target_position = 0.5; target_velocity = 0.0; time_to_reach = 0.5 }
  ] in
  let sps = generate_setpoints traj 10.0 in
  let rates = List.map (fun _ -> 0.2) sps in
  let cmds = to_actuator_commands sps rates in
  Alcotest.(check int) "commands match" (List.length sps) (List.length cmds);
  match cmds with
  | c :: _ -> Alcotest.(check (float 0.001)) "rate preserved" 0.2 c.rate_limit
  | [] -> Alcotest.fail "no commands"

let test_commands_default_rate () =
  let traj = mk_traj [
    { target_position = 0.5; target_velocity = 0.0; time_to_reach = 0.5 }
  ] in
  let sps = generate_setpoints traj 10.0 in
  let cmds = to_actuator_commands sps [] in
  match cmds with
  | c :: _ -> Alcotest.(check (float 0.001)) "default rate" 0.1 c.rate_limit
  | [] -> Alcotest.fail "no commands"

let () =
  Alcotest.run "Setpoint_gen_perf" [
    "empty", [ Alcotest.test_case "no waypoints" `Quick test_empty_trajectory ];
    "single", [ Alcotest.test_case "single waypoint" `Quick test_single_waypoint ];
    "ordering", [ Alcotest.test_case "monotonic" `Quick test_ordering ];
    "step_count", [ Alcotest.test_case "higher freq" `Quick test_step_count ];
    "commands_match", [ Alcotest.test_case "rates supplied" `Quick test_commands_with_rates ];
    "commands_default", [ Alcotest.test_case "no rates" `Quick test_commands_default_rate ];
  ]
