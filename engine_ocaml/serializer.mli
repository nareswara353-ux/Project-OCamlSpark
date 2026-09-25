open Trajectory_types

val serialize_state : state -> string
val deserialize_state : string -> (state, Error.t) result
val serialize_command : actuator_command -> string
val deserialize_command : string -> (actuator_command, Error.t) result
val serialize_trajectory : trajectory -> string
val deserialize_trajectory : string -> (trajectory, Error.t) result
val serialize_command_list : actuator_command list -> string
val deserialize_command_list : string -> (actuator_command list, Error.t) result
