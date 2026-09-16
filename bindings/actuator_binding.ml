open Ctypes
open Foreign

external ocaml_force_link : unit -> unit = "ocaml_force_link"
let () = ocaml_force_link ()

type command = { target_deflection : float; rate_limit : float }
type limits = { max_deflection : float; min_deflection : float }

let command_struct : [ `Struct ] structure typ = structure "command_t"
let command_target_deflection = field command_struct "target_deflection" double
let command_rate_limit = field command_struct "rate_limit" double
let () = seal command_struct

let limits_struct : [ `Struct ] structure typ = structure "limits_t"
let limits_max_deflection = field limits_struct "max_deflection" double
let limits_min_deflection = field limits_struct "min_deflection" double
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
    (double @-> double @-> double @-> double @-> double @-> returning bool)

let apply_limits_foreign =
  foreign "apply_limits"
    (ptr command_struct @-> ptr limits_struct @-> ptr command_struct @-> returning void)

let majority_vote_foreign =
  foreign "majority_vote"
    (ptr command_struct @-> ptr command_struct @-> ptr command_struct
     @-> ptr limits_struct @-> ptr command_struct @-> returning void)

let is_consensus_foreign =
  foreign "is_consensus"
    (ptr command_struct @-> ptr command_struct @-> ptr command_struct
     @-> double @-> returning bool)

let validate_command current target max_rate max_def min_def =
  validate_command_foreign current target max_rate max_def min_def

let apply_limits cmd lim =
  let cmd_c = command_to_c cmd in
  let lim_c = limits_to_c lim in
  let out = make command_struct in
  apply_limits_foreign (addr cmd_c) (addr lim_c) (addr out);
  command_of_c out

let majority_vote c1 c2 c3 lim =
  let c1_c = command_to_c c1 in
  let c2_c = command_to_c c2 in
  let c3_c = command_to_c c3 in
  let lim_c = limits_to_c lim in
  let out = make command_struct in
  majority_vote_foreign (addr c1_c) (addr c2_c) (addr c3_c) (addr lim_c) (addr out);
  command_of_c out

let is_consensus c1 c2 c3 tolerance =
  let c1_c = command_to_c c1 in
  let c2_c = command_to_c c2 in
  let c3_c = command_to_c c3 in
  is_consensus_foreign (addr c1_c) (addr c2_c) (addr c3_c) tolerance
