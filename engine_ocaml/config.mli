type t = {
  control_freq_hz : float;
  max_deflection : float;
  min_deflection : float;
  max_rate_limit : float;
  sensor_timeout_s : float;
  log_min_level : string;
  telemetry_capacity : int;
}

val default : t
val validate : t -> (t, string) result
val get_control_freq : t -> float
val get_limits : t -> float * float
val with_control_freq : t -> float -> t
val with_limits : t -> float -> float -> t
