open Trajectory_types

val sanitize_float : default:float -> float -> float
val sanitize_command : actuator_command -> float -> float -> actuator_command
val sanitize_waypoint : waypoint -> waypoint
val sanitize_state : state -> state
val clamp : float -> float -> float -> float
val normalize_rate : float -> float
