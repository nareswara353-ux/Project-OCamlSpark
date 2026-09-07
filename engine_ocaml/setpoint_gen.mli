open Trajectory_types

val generate_setpoints : trajectory -> float -> (float * float) list
val to_actuator_commands : (float * float) list -> float list -> actuator_command list
val generate_commands : trajectory -> float -> float list -> actuator_command list
