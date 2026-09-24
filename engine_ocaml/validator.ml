open Trajectory_types

let validate_waypoint wp =
  if wp.time_to_reach <= 0.0 then
    Error (Error.validation "WP_TIME" "time_to_reach must be positive")
  else if Float.is_nan wp.target_position || Float.is_infinite wp.target_position then
    Error (Error.validation "WP_POS" "target_position must be finite")
  else if Float.is_nan wp.target_velocity || Float.is_infinite wp.target_velocity then
    Error (Error.validation "WP_VEL" "target_velocity must be finite")
  else
    Ok wp

let validate_trajectory traj =
  let rec check = function
    | [] -> Ok ()
    | wp :: rest ->
        (match validate_waypoint wp with
         | Error e -> Error e
         | Ok _ -> check rest)
  in
  if traj.duration < 0.0 then
    Error (Error.validation "TRAJ_DURATION" "duration must be non-negative")
  else
    match check traj.waypoints with
    | Error e -> Error e
    | Ok () -> Ok traj

let validate_limits max_d min_d =
  if max_d <= min_d then
    Error (Error.validation "LIMIT_ORDER" "max_deflection must exceed min_deflection")
  else if max_d > 1.0 || min_d < -1.0 then
    Error (Error.validation "LIMIT_RANGE" "deflection limits must be within [-1, 1]")
  else
    Ok ()

let validate_command cmd max_d min_d =
  if Float.is_nan cmd.deflection then
    Error (Error.validation "CMD_NAN" "deflection is NaN")
  else if cmd.deflection > max_d || cmd.deflection < min_d then
    Error (Error.validation "CMD_RANGE" "deflection out of limits")
  else if cmd.rate_limit < 0.0 || cmd.rate_limit > 1.0 then
    Error (Error.validation "CMD_RATE" "rate_limit must be in [0, 1]")
  else
    Ok cmd

let validate_trajectory_parameters params =
  if params.max_accel <= 0.0 then
    Error (Error.validation "PARAM_ACCEL" "max_accel must be positive")
  else if params.max_velocity <= 0.0 then
    Error (Error.validation "PARAM_VEL" "max_velocity must be positive")
  else if params.jerk_limit < 0.0 then
    Error (Error.validation "PARAM_JERK" "jerk_limit must be non-negative")
  else
    Ok params
