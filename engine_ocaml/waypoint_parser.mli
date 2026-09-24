open Trajectory_types

val parse_line : string -> (waypoint, Error.t) result
val parse_lines : string list -> (waypoint list, Error.t) result
val parse_string : string -> (waypoint list, Error.t) result
val render_line : waypoint -> string
val render_lines : waypoint list -> string
