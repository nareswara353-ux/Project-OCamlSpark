type t = {
  control_freq_hz : float;
  max_deflection : float;
  min_deflection : float;
  max_rate_limit : float;
  sensor_timeout_s : float;
  log_min_level : string;
  telemetry_capacity : int;
}

let default = {
  control_freq_hz = 20.0;
  max_deflection = 0.95;
  min_deflection = -0.95;
  max_rate_limit = 0.5;
  sensor_timeout_s = 0.5;
  log_min_level = "INFO";
  telemetry_capacity = 1000;
}

let validate cfg =
  if cfg.control_freq_hz <= 0.0 then Error "control_freq_hz must be positive"
  else if cfg.max_deflection <= cfg.min_deflection then Error "max_deflection must exceed min_deflection"
  else if cfg.max_deflection > 1.0 || cfg.min_deflection < -1.0 then Error "deflection limits outside [-1, 1]"
  else if cfg.max_rate_limit <= 0.0 then Error "max_rate_limit must be positive"
  else if cfg.sensor_timeout_s <= 0.0 then Error "sensor_timeout_s must be positive"
  else if cfg.telemetry_capacity <= 0 then Error "telemetry_capacity must be positive"
  else Ok cfg

let get_control_freq cfg = cfg.control_freq_hz
let get_limits cfg = (cfg.max_deflection, cfg.min_deflection)

let with_control_freq cfg freq = { cfg with control_freq_hz = freq }
let with_limits cfg max_d min_d = { cfg with max_deflection = max_d; min_deflection = min_d }
