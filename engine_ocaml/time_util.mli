val now : unit -> float
val elapsed_since : float -> float
val diff : float -> float -> float
val add_seconds : float -> float -> float
val is_expired : float -> float -> bool
val format_iso8601 : float -> string
val format_duration : float -> string
val seconds_to_ms : float -> float
val ms_to_seconds : float -> float
val sample_period : float -> float list -> float list
