open Trajectory_types

val create_trajectory : state -> waypoint list -> trajectory_parameters -> trajectory
val generate_actuator_commands : trajectory -> float -> float list -> actuator_command list
val optimize_and_convert : state -> waypoint list -> trajectory_parameters -> float -> float list -> actuator_command list
val validate_trajectory : trajectory -> bool
val get_duration : trajectory -> float
val get_waypoints : trajectory -> waypoint list
val get_start_state : trajectory -> state
