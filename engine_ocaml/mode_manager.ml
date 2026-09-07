open Trajectory_types

type mode_state = {
  current_mode : flight_mode;
  last_command : actuator_command option;
  emergency_override : bool;
}

let initial_mode_state = {
  current_mode = Manual;
  last_command = None;
  emergency_override = false;
}

let transition (state : mode_state) (new_mode : flight_mode) (override : bool) : mode_state =
  match new_mode with
  | Manual -> { state with current_mode = Manual; emergency_override = override }
  | AutoPilot -> { state with current_mode = AutoPilot; emergency_override = override }
  | Emergency -> { state with current_mode = Emergency; emergency_override = true }

let is_mode_allowed (mode : flight_mode) (override : bool) : bool =
  match mode with
  | Emergency -> true
  | AutoPilot -> not override
  | Manual -> true

let get_rate_limit_for_mode (mode : flight_mode) : float =
  match mode with
  | Manual -> 0.5
  | AutoPilot -> 0.1
  | Emergency -> 0.01

let apply_mode_limits (cmd : actuator_command) (mode : flight_mode) : actuator_command =
  let max_rate = get_rate_limit_for_mode mode in
  let limited_rate = if cmd.rate_limit > max_rate then max_rate else cmd.rate_limit in
  { cmd with rate_limit = limited_rate }

let process_command (state : mode_state) (cmd : actuator_command) : actuator_command * mode_state =
  let adjusted_cmd = apply_mode_limits cmd state.current_mode in
  let new_state = { state with last_command = Some adjusted_cmd } in
  (adjusted_cmd, new_state)

let emergency_override_command (state : mode_state) (override_deflection : float) : actuator_command * mode_state =
  let emergency_cmd = { deflection = override_deflection; rate_limit = 0.01 } in
  let new_state = { state with current_mode = Emergency; emergency_override = true; last_command = Some emergency_cmd } in
  (emergency_cmd, new_state)

let is_emergency_active (state : mode_state) : bool =
  state.current_mode = Emergency || state.emergency_override

let get_current_mode (state : mode_state) : flight_mode =
  state.current_mode
