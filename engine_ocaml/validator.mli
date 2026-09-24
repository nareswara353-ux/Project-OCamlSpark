open Trajectory_types

val validate_waypoint : waypoint -> (waypoint, Error.t) result
val validate_trajectory : trajectory -> (trajectory, Error.t) result
val validate_command : actuator_command -> float -> float -> (actuator_command, Error.t) result
val validate_limits : float -> float -> (unit, Error.t) result
val validate_trajectory_parameters : trajectory_parameters -> (trajectory_parameters, Error.t) result
