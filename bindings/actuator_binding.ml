open Ctypes
open Foreign

type deflection = float
type command = { target_deflection : deflection; rate_limit : float }
type limits = { max_deflection : deflection; min_deflection : deflection }
type health_status = Healthy | Degraded | Failed

let command_t =
  struct
    field "target_deflection" float;
    field "rate_limit" float;
  end

let limits_t =
  struct
    field "max_deflection" float;
    field "min_deflection" float;
  end

let command_of_ptr p =
  let t = !@p in
  { target_deflection = getf t target_deflection; rate_limit = getf t rate_limit }

let limits_of_ptr p =
  let t = !@p in
  { max_deflection = getf t max_deflection; min_deflection = getf t min_deflection }

let validate_command_foreign =
  foreign "validate_command" (float @-> float @-> float @-> float @-> float @-> returning bool)

let apply_limits_foreign =
  foreign "apply_limits" (ptr command_t @-> ptr limits_t @-> returning command_t)

let is_within_limits_foreign =
  foreign "is_within_limits" (float @-> ptr limits_t @-> returning bool)

let majority_vote_foreign =
  foreign "majority_vote" (ptr command_t @-> ptr command_t @-> ptr command_t @-> ptr limits_t @-> returning command_t)

let is_consensus_foreign =
  foreign "is_consensus" (ptr command_t @-> ptr command_t @-> ptr command_t @-> float @-> returning bool)

let validate_command current target max_rate max_def min_def =
  validate_command_foreign current target max_rate max_def min_def

let apply_limits cmd lim =
  let cmd_ptr = allocate command_t { target_deflection = cmd.target_deflection; rate_limit = cmd.rate_limit } in
  let lim_ptr = allocate limits_t { max_deflection = lim.max_deflection; min_deflection = lim.min_deflection } in
  let res = apply_limits_foreign cmd_ptr lim_ptr in
  command_of_ptr (addr res)

let is_within_limits value lim =
  let lim_ptr = allocate limits_t { max_deflection = lim.max_deflection; min_deflection = lim.min_deflection } in
  is_within_limits_foreign value lim_ptr

let majority_vote c1 c2 c3 lim =
  let c1_ptr = allocate command_t { target_deflection = c1.target_deflection; rate_limit = c1.rate_limit } in
  let c2_ptr = allocate command_t { target_deflection = c2.target_deflection; rate_limit = c2.rate_limit } in
  let c3_ptr = allocate command_t { target_deflection = c3.target_deflection; rate_limit = c3.rate_limit } in
  let lim_ptr = allocate limits_t { max_deflection = lim.max_deflection; min_deflection = lim.min_deflection } in
  let res = majority_vote_foreign c1_ptr c2_ptr c3_ptr lim_ptr in
  command_of_ptr (addr res)

let is_consensus c1 c2 c3 tolerance =
  let c1_ptr = allocate command_t { target_deflection = c1.target_deflection; rate_limit = c1.rate_limit } in
  let c2_ptr = allocate command_t { target_deflection = c2.target_deflection; rate_limit = c2.rate_limit } in
  let c3_ptr = allocate command_t { target_deflection = c3.target_deflection; rate_limit = c3.rate_limit } in
  is_consensus_foreign c1_ptr c2_ptr c3_ptr tolerance
