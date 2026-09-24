type level = Debug | Info | Warn | Error

type entry = {
  timestamp : float;
  level : level;
  module_name : string;
  message : string;
  context : (string * string) list;
}

type t

val create : ?min_level:level -> ?sink:(entry -> unit) -> unit -> t
val set_min_level : t -> level -> unit
val get_min_level : t -> level
val log : t -> level -> string -> string -> (string * string) list -> unit
val debug : t -> string -> string -> (string * string) list -> unit
val info : t -> string -> string -> (string * string) list -> unit
val warn : t -> string -> string -> (string * string) list -> unit
val error : t -> string -> string -> (string * string) list -> unit
val level_to_string : level -> string
val string_to_level : string -> level
