open Trajectory_types

type snapshot = {
  timestamp : float;
  mode : flight_mode;
  deflection : float;
  rate_limit : float;
  position : float;
  velocity : float;
  is_safe : bool;
}

type t = {
  buffer : snapshot Ring_buffer.t;
}

let create () = {
  buffer = Ring_buffer.create 1000;
}

let record t snap =
  Ring_buffer.push t.buffer snap

let latest t =
  if Ring_buffer.is_empty t.buffer then None
  else
    let items = Ring_buffer.to_list t.buffer in
    match List.rev items with
    | [] -> None
    | x :: _ -> Some x

let history t = Ring_buffer.to_list t.buffer

let count t = Ring_buffer.length t.buffer

let clear t = Ring_buffer.clear t.buffer

let snapshot_of_state timestamp mode cmd state is_safe = {
  timestamp;
  mode;
  deflection = cmd.deflection;
  rate_limit = cmd.rate_limit;
  position = state.position;
  velocity = state.velocity;
  is_safe;
}
