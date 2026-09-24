open Trajectory_types

let sanitize_float ~default v =
  if Float.is_nan v || Float.is_infinite v then default else v

let clamp v lo hi =
  if Float.is_nan v then lo
  else if v < lo then lo
  else if v > hi then hi
  else v

let normalize_rate r =
  if Float.is_nan r || Float.is_infinite r then 0.0
  else if r < 0.0 then 0.0
  else if r > 1.0 then 1.0
  else r

let sanitize_command cmd max_d min_d =
  let d = clamp cmd.deflection min_d max_d in
  let r = normalize_rate cmd.rate_limit in
  { deflection = d; rate_limit = r }

let sanitize_waypoint wp =
  { target_position = sanitize_float ~default:0.0 wp.target_position;
    target_velocity = sanitize_float ~default:0.0 wp.target_velocity;
    time_to_reach = (let t = sanitize_float ~default:1.0 wp.time_to_reach in
                     if t <= 0.0 then 1.0 else t) }

let sanitize_state s =
  { position = sanitize_float ~default:0.0 s.position;
    velocity = sanitize_float ~default:0.0 s.velocity;
    acceleration = sanitize_float ~default:0.0 s.acceleration;
    timestamp = sanitize_float ~default:0.0 s.timestamp }
