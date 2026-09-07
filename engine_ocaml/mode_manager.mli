open Trajectory_types

type mode_state

val initial_mode_state : mode_state
val transition : mode_state -> flight_mode -> bool -> mode_state
val is_mode_allowed : flight_mode -> bool -> bool
val get_rate_limit_for_mode : flight_mode -> float
val apply_mode_limits : actuator_command -> flight_mode -> actuator_command
val process_command : mode_state -> actuator_command -> actuator_command * mode_state
val emergency_override_command : mode_state -> float -> actuator_command * mode_state
val is_emergency_active : mode_state -> bool
val get_current_mode : mode_state -> flight_mode
