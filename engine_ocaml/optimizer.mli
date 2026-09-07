open Trajectory_types

val compute_trajectory : state -> waypoint list -> trajectory_parameters -> trajectory
val extract_commands : trajectory -> actuator_command list
