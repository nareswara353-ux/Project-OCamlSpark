open Trajectory_types

let split_fields s =
  String.split_on_char '|' s |> List.map String.trim

let parse_floats fields =
  try
    let floats = List.map float_of_string fields in
    Ok floats
  with Failure msg -> Error (Error.validation "SER_FLOAT" msg)

let serialize_state s =
  Printf.sprintf "%.6f|%.6f|%.6f|%.6f"
    s.position s.velocity s.acceleration s.timestamp

let deserialize_state line =
  match split_fields line with
  | [p; v; a; t] ->
      (match parse_floats [p; v; a; t] with
       | Error e -> Error e
       | Ok [pf; vf; af; tf] ->
           Ok { position = pf; velocity = vf; acceleration = af; timestamp = tf }
       | Ok _ -> Error (Error.validation "SER_STATE" "unexpected field count"))
  | _ -> Error (Error.validation "SER_STATE" "expected 4 fields")

let serialize_command cmd =
  Printf.sprintf "%.6f|%.6f" cmd.deflection cmd.rate_limit

let deserialize_command line =
  match split_fields line with
  | [d; r] ->
      (match parse_floats [d; r] with
       | Error e -> Error e
       | Ok [df; rf] -> Ok { deflection = df; rate_limit = rf }
       | Ok _ -> Error (Error.validation "SER_CMD" "unexpected field count"))
  | _ -> Error (Error.validation "SER_CMD" "expected 2 fields")

let serialize_trajectory traj =
  let header =
    Printf.sprintf "TRAJ|%.6f|%s"
      traj.duration
      (serialize_state traj.start_state)
  in
  let waypoints =
    traj.waypoints
    |> List.map (fun w ->
         Printf.sprintf "WP|%.6f|%.6f|%.6f"
           w.target_position w.target_velocity w.time_to_reach)
  in
  String.concat "\n" (header :: waypoints)

let deserialize_trajectory content =
  let lines = String.split_on_char '\n' content in
  match lines with
  | [] -> Error (Error.validation "SER_TRAJ" "empty trajectory")
  | header :: rest ->
      let header_fields = split_fields header in
      (match header_fields with
       | ["TRAJ"; dur; st] ->
           (match float_of_string_opt dur, deserialize_state st with
            | Some duration, Ok start_state ->
                let rec parse_wps acc = function
                  | [] -> Ok (List.rev acc)
                  | line :: tail ->
                      let line = String.trim line in
                      if line = "" then parse_wps acc tail
                      else
                        let fs = split_fields line in
                        (match fs with
                         | ["WP"; p; v; t] ->
                             (match parse_floats [p; v; t] with
                              | Ok [pf; vf; tf] ->
                                  parse_wps ({ target_position = pf;
                                               target_velocity = vf;
                                               time_to_reach = tf } :: acc) tail
                              | Ok _ -> Error (Error.validation "SER_WP" "field count")
                              | Error e -> Error e)
                         | _ -> Error (Error.validation "SER_WP" "malformed waypoint line"))
                in
                (match parse_wps [] rest with
                 | Error e -> Error e
                 | Ok waypoints ->
                     Ok { waypoints; start_state; duration })
            | _ -> Error (Error.validation "SER_TRAJ" "invalid header"))
       | _ -> Error (Error.validation "SER_TRAJ" "expected TRAJ header"))

let serialize_command_list cmds =
  cmds
  |> List.map serialize_command
  |> String.concat "\n"

let deserialize_command_list content =
  let lines = String.split_on_char '\n' content in
  let rec loop acc = function
    | [] -> Ok (List.rev acc)
    | line :: rest ->
        let line = String.trim line in
        if line = "" then loop acc rest
        else
          match deserialize_command line with
          | Ok cmd -> loop (cmd :: acc) rest
          | Error e -> Error e
  in
  loop [] lines
