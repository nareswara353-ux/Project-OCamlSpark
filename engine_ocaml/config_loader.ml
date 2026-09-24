let float_of_string_opt s =
  try Some (float_of_string s) with _ -> None

let int_of_string_opt s =
  try Some (int_of_string s) with _ -> None

let parse_kv_line line =
  match String.index_opt line '=' with
  | None -> None
  | Some idx ->
      let k = String.sub line 0 idx |> String.trim in
      let v = String.sub line (idx + 1) (String.length line - idx - 1) |> String.trim in
      if k = "" then None else Some (k, v)

let from_kv_list kv =
  let cfg = ref Config.default in
  List.iter (fun (k, v) ->
    match k with
    | "control_freq_hz" ->
        (match float_of_string_opt v with Some x -> cfg := { !cfg with Config.control_freq_hz = x } | None -> ())
    | "max_deflection" ->
        (match float_of_string_opt v with Some x -> cfg := { !cfg with Config.max_deflection = x } | None -> ())
    | "min_deflection" ->
        (match float_of_string_opt v with Some x -> cfg := { !cfg with Config.min_deflection = x } | None -> ())
    | "max_rate_limit" ->
        (match float_of_string_opt v with Some x -> cfg := { !cfg with Config.max_rate_limit = x } | None -> ())
    | "sensor_timeout_s" ->
        (match float_of_string_opt v with Some x -> cfg := { !cfg with Config.sensor_timeout_s = x } | None -> ())
    | "log_min_level" ->
        cfg := { !cfg with Config.log_min_level = v }
    | "telemetry_capacity" ->
        (match int_of_string_opt v with Some x -> cfg := { !cfg with Config.telemetry_capacity = x } | None -> ())
    | _ -> ()
  ) kv;
  !cfg

let from_env () =
  let prefix = "ACTUATOR_" in
  let get name =
    match Sys.getenv_opt (prefix ^ name) with
    | Some v -> Some (String.lowercase_ascii name, v)
    | None -> None
  in
  let keys = [
    "CONTROL_FREQ_HZ", "control_freq_hz";
    "MAX_DEFLECTION", "max_deflection";
    "MIN_DEFLECTION", "min_deflection";
    "MAX_RATE_LIMIT", "max_rate_limit";
    "SENSOR_TIMEOUT_S", "sensor_timeout_s";
    "LOG_MIN_LEVEL", "log_min_level";
    "TELEMETRY_CAPACITY", "telemetry_capacity";
  ] in
  let kv = List.filter_map (fun (env_key, target) ->
    match Sys.getenv_opt (prefix ^ env_key) with
    | Some v -> Some (target, v)
    | None -> None
  ) keys in
  ignore get;
  from_kv_list kv

let load ?(env = true) ?(kv = []) () =
  let base = if env then from_env () else Config.default in
  let merged = from_kv_list kv in
  let final =
    if env then begin
      let env_cfg = base in
      {
        Config.control_freq_hz = env_cfg.Config.control_freq_hz;
        max_deflection = env_cfg.Config.max_deflection;
        min_deflection = env_cfg.Config.min_deflection;
        max_rate_limit = env_cfg.Config.max_rate_limit;
        sensor_timeout_s = env_cfg.Config.sensor_timeout_s;
        log_min_level = env_cfg.Config.log_min_level;
        telemetry_capacity = env_cfg.Config.telemetry_capacity;
      }
    end else merged
  in
  Config.validate final
