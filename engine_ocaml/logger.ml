type level = Debug | Info | Warn | Error

type entry = {
  timestamp : float;
  level : level;
  module_name : string;
  message : string;
  context : (string * string) list;
}

type t = {
  mutable min_level : level;
  mutable sink : entry -> unit;
}

let level_to_int = function
  | Debug -> 0
  | Info -> 1
  | Warn -> 2
  | Error -> 3

let level_to_string = function
  | Debug -> "DEBUG"
  | Info -> "INFO"
  | Warn -> "WARN"
  | Error -> "ERROR"

let string_to_level = function
  | "DEBUG" | "debug" -> Debug
  | "INFO" | "info" -> Info
  | "WARN" | "warn" -> Warn
  | "ERROR" | "error" -> Error
  | _ -> Info

let default_sink entry =
  let ctx =
    entry.context
    |> List.map (fun (k, v) -> k ^ "=" ^ v)
    |> String.concat " "
  in
  let line =
    Printf.sprintf "[%.6f] [%s] [%s] %s %s"
      entry.timestamp
      (level_to_string entry.level)
      entry.module_name
      entry.message
      ctx
  in
  prerr_endline line

let create ?(min_level = Info) ?(sink = default_sink) () =
  { min_level; sink }

let set_min_level t level = t.min_level <- level
let get_min_level t = t.min_level

let log t level module_name message context =
  if level_to_int level >= level_to_int t.min_level then begin
    let entry = {
      timestamp = Unix.gettimeofday ();
      level;
      module_name;
      message;
      context;
    } in
    t.sink entry
  end

let debug t m msg ctx = log t Debug m msg ctx
let info t m msg ctx = log t Info m msg ctx
let warn t m msg ctx = log t Warn m msg ctx
let error t m msg ctx = log t Error m msg ctx
