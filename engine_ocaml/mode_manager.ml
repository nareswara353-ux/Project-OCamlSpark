open Trajectory_types

type mode_state = {
  current_mode : flight_mode;
  emergency_override : bool;
}

let initial_mode_state = {
  current_mode = Manual;
  emergency_override = false;
}

let transition _state new_mode override =
  match new_mode with
  | Manual -> { current_mode = Manual; emergency_override = override }
  | AutoPilot -> { current_mode = AutoPilot; emergency_override = override }
  | Emergency -> { current_mode = Emergency; emergency_override = true }

let is_mode_allowed mode override =
  match mode with
  | Emergency -> true
  | AutoPilot -> not override
  | Manual -> true

let get_rate_limit_for_mode mode =
  match mode with
  | Manual -> 0.5
  | AutoPilot -> 0.1
  | Emergency -> 0.01

let apply_mode_limits cmd mode =
  let max_rate = get_rate_limit_for_mode mode in
  let limited_rate = if cmd.rate_limit > max_rate then max_rate else cmd.rate_limit in
  { cmd with rate_limit = limited_rate }

let process_command state cmd =
  let adjusted_cmd = apply_mode_limits cmd state.current_mode in
  (adjusted_cmd, state)

let emergency_override_command _state override_deflection =
  let emergency_cmd = { deflection = override_deflection; rate_limit = 0.01 } in
  let new_state = { current_mode = Emergency; emergency_override = true } in
  (emergency_cmd, new_state)

let is_emergency_active state =
  state.current_mode = Emergency || state.emergency_override

let get_current_mode state =
  state.current_mode
