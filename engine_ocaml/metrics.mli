type t

type histogram = {
  count : int;
  min : float;
  max : float;
  mean : float;
  p50 : float;
  p99 : float;
}

val create : unit -> t
val incr : t -> string -> unit
val add : t -> string -> float -> unit
val set_gauge : t -> string -> float -> unit
val observe : t -> string -> float -> unit
val get_counter : t -> string -> float
val get_gauge : t -> string -> float
val get_histogram : t -> string -> histogram option
val snapshot : t -> (string * float) list
val reset : t -> unit
