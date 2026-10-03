open Trajectory_types
open Waypoint_parser
open Serializer

let time_it label f =
  let start = Unix.gettimeofday () in
  let result = f () in
  let elapsed = Unix.gettimeofday () -. start in
  Printf.printf "%-40s %8.3f ms\n" label (elapsed *. 1000.0);
  result

let make_lines n =
  let rec loop i acc =
    if i >= n then List.rev acc
    else
      let line = Printf.sprintf "%.3f,%.3f,%.3f"
        (0.1 *. float_of_int (i mod 10))
        (0.05 *. float_of_int (i mod 5))
        (0.5 +. 0.1 *. float_of_int (i mod 3))
      in
      loop (i + 1) (line :: acc)
  in
  loop 0 []

let bench_parser n =
  let lines = make_lines n in
  time_it (Printf.sprintf "parse_lines(%d)" n)
    (fun () -> parse_lines lines)

let bench_render n =
  let lines = make_lines n in
  match parse_lines lines with
  | Ok wps ->
      time_it (Printf.sprintf "render_lines(%d)" n)
        (fun () -> render_lines wps)
  | Error _ -> (Printf.printf "skip render(%d): parse failed\n" n; "")

let bench_serialize_state n =
  let s = { position = 1.5; velocity = 0.3; acceleration = 0.0; timestamp = 0.0 } in
  time_it (Printf.sprintf "serialize_state(%d)" n)
    (fun () ->
       let rec loop i acc =
         if i >= n then acc
         else loop (i + 1) (serialize_state s)
       in
       loop 0 "")

let bench_command_roundtrip n =
  let cmds = List.init n (fun i ->
    { deflection = 0.01 *. float_of_int i; rate_limit = 0.1 }) in
  time_it (Printf.sprintf "command_roundtrip(%d)" n)
    (fun () ->
       let encoded = serialize_command_list cmds in
       deserialize_command_list encoded)

let () =
  Printf.printf "=== Parser & Serializer Benchmarks ===\n\n";
  ignore (bench_parser 10);
  ignore (bench_parser 100);
  ignore (bench_parser 1000);
  ignore (bench_parser 10000);
  Printf.printf "\n";
  ignore (bench_render 100);
  ignore (bench_render 1000);
  Printf.printf "\n";
  ignore (bench_serialize_state 1000);
  ignore (bench_serialize_state 10000);
  Printf.printf "\n";
  ignore (bench_command_roundtrip 100);
  ignore (bench_command_roundtrip 1000);
  Printf.printf "\nDone.\n"
