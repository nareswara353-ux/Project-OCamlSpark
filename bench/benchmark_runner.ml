open Trajectory_types
open Optimizer
open Setpoint_gen

let time_it label f =
  let start = Unix.gettimeofday () in
  let result = f () in
  let elapsed = Unix.gettimeofday () -. start in
  Printf.printf "%-40s %8.3f ms\n" label (elapsed *. 1000.0);
  result

let make_waypoints n =
  let rec loop i acc =
    if i >= n then List.rev acc
    else
      let wp = {
        target_position = 0.1 *. float_of_int (i mod 10);
        target_velocity = 0.05 *. float_of_int (i mod 5);
        time_to_reach = 0.5 +. 0.1 *. float_of_int (i mod 3);
      } in
      loop (i + 1) (wp :: acc)
  in
  loop 0 []

let bench_trajectory n =
  let start = { position = 0.0; velocity = 0.0; acceleration = 0.0; timestamp = 0.0 } in
  let wps = make_waypoints n in
  let params = { max_accel = 1.0; max_velocity = 1.0; jerk_limit = 0.5 } in
  time_it (Printf.sprintf "trajectory(%d waypoints)" n)
    (fun () -> compute_trajectory start wps params)

let bench_commands n freq =
  let start = { position = 0.0; velocity = 0.0; acceleration = 0.0; timestamp = 0.0 } in
  let wps = make_waypoints n in
  let params = { max_accel = 1.0; max_velocity = 1.0; jerk_limit = 0.5 } in
  let traj = compute_trajectory start wps params in
  time_it (Printf.sprintf "commands(%d waypoints @ %.0f Hz)" n freq)
    (fun () -> generate_commands traj freq [])

let () =
  Printf.printf "=== Actuator Engine Benchmarks ===\n\n";
  ignore (bench_trajectory 10);
  ignore (bench_trajectory 100);
  ignore (bench_trajectory 1000);
  Printf.printf "\n";
  ignore (bench_commands 10 20.0);
  ignore (bench_commands 100 20.0);
  ignore (bench_commands 100 50.0);
  ignore (bench_commands 1000 20.0);
  Printf.printf "\nDone.\n"
