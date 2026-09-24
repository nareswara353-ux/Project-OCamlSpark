open Trajectory_types

type snapshot = {
  timestamp : float;
  mode : flight_mode;
  deflection : float;
  rate_limit : float;
  position : float;
  velocity : float;
  is_safe : bool;
}

type t

val create : unit -> t
val record : t -> snapshot -> unit
val latest : t -> snapshot option
val history : t -> snapshot list
val count : t -> int
val clear : t -> unit
val snapshot_of_state : float -> flight_mode -> actuator_command -> state -> bool -> snapshot
