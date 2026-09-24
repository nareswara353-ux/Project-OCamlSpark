val from_env : unit -> Config.t
val from_kv_list : (string * string) list -> Config.t
val load : ?env:bool -> ?kv:(string * string) list -> unit -> (Config.t, string) result
val parse_kv_line : string -> (string * string) option
