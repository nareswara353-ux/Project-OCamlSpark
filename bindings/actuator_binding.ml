open Ctypes
open Foreign

type command = { target_deflection : float; rate_limit : float }
type limits = { max_deflection : float; min_deflection : float }

let command_struct = structure "command_t"
let command_target_deflection = field command_struct "target_deflection" float
let command_rate_limit = field command_struct "rate_limit" float
let () = seal command_struct

let limits_struct = structure "limits_t"
let limits_max_deflection = field limits_struct "max_deflection" float
let limits_min_deflection = field limits_struct "min_deflection" float
let () = seal limits_struct

let command_of_c t =
  { target_deflection = getf t command_target_deflection;
    rate_limit = getf t command_rate_limit }

let command_to_c c =
  let t = make command_struct in
  setf t command_target_deflection c.target_deflection;
  setf t command_rate_limit c.rate_limit;
  t

let limits_to_c l =
  let t = make limits_struct in
  setf t limits_max_deflection l.max_deflection;
  setf t limits_min_deflection l.min_deflection;
  t

let validate_command_foreign =
  foreign "validate_command"
    (float @-> float @-> float @-> float @-> float @-> returning bool)

let apply_limits_foreign =
  foreign "apply_limits" (command_struct @-> limits_struct @-> returning command_struct)

let majority_vote_foreign =
  foreign "majority_vote"
    (command_struct @-> command_struct @-> command_struct @-> limits_struct @-> returning command_struct)

let is_consensus_foreign =
  foreign "is_consensus"
    (command_struct @-> command_struct @-> command_struct @-> float @-> returning bool)

let validate_command current target max_rate max_def min_def =
  validate_command_foreign current target max_rate max_def min_def

let apply_limits cmd lim =
  command_of_c (apply_limits_foreign (command_to_c cmd) (limits_to_c lim))

let majority_vote c1 c2 c3 lim =
  command_of_c
    (majority_vote_foreign (command_to_c c1) (command_to_c c2) (command_to_c c3)
       (limits_to_c lim))

let is_consensus c1 c2 c3 tolerance =
  is_consensus_foreign (command_to_c c1) (command_to_c c2) (command_to_c c3)
    tolerance
