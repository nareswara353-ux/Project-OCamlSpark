open Trajectory_types

let parse_line line =
  let line = String.trim line in
  if line = "" || String.length line > 0 && line.[0] = '#' then
    Error (Error.validation "PARSE_EMPTY" "empty or comment line")
  else
    let parts = String.split_on_char ',' line in
    match parts with
    | [p; v; t] ->
        (try
           let pos = float_of_string (String.trim p) in
           let vel = float_of_string (String.trim v) in
           let time = float_of_string (String.trim t) in
           if Float.is_nan pos || Float.is_nan vel || Float.is_nan time then
             Error (Error.validation "PARSE_NAN" "NaN not allowed in waypoint")
           else if time <= 0.0 then
             Error (Error.validation "PARSE_TIME" "time_to_reach must be positive")
           else
             Ok { target_position = pos; target_velocity = vel; time_to_reach = time }
         with Failure _ ->
           Error (Error.validation "PARSE_FLOAT" ("invalid float in line: " ^ line)))
    | _ ->
        Error (Error.validation "PARSE_FIELDS" "expected 3 fields: pos,vel,time")

let parse_lines lines =
  let rec loop acc = function
    | [] -> Ok (List.rev acc)
    | line :: rest ->
        (match parse_line line with
         | Ok wp -> loop (wp :: acc) rest
         | Error e ->
             let line = String.trim line in
             if line = "" || (String.length line > 0 && line.[0] = '#') then
               loop acc rest
             else
               Error e)
  in
  loop [] lines

let parse_string content =
  let lines = String.split_on_char '\n' content in
  parse_lines lines

let render_line wp =
  Printf.sprintf "%.6f,%.6f,%.6f"
    wp.target_position wp.target_velocity wp.time_to_reach

let render_lines wps =
  wps
  |> List.map render_line
  |> String.concat "\n"
