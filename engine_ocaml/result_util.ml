let is_ok = function Ok _ -> true | Error _ -> false
let is_error = function Error _ -> true | Ok _ -> false

let get_or_default ~default = function
  | Ok v -> v
  | Error _ -> default

let get_or_else f = function
  | Ok v -> v
  | Error e -> f e

let to_option = function
  | Ok v -> Some v
  | Error _ -> None

let of_option ~error = function
  | Some v -> Ok v
  | None -> Error error

let map_error f = function
  | Ok v -> Ok v
  | Error e -> Error (f e)

let all results =
  let rec loop acc = function
    | [] -> Ok (List.rev acc)
    | Ok v :: rest -> loop (v :: acc) rest
    | Error e :: _ -> Error e
  in
  loop [] results

let any results =
  let rec loop = function
    | [] -> Error `No_success
    | Ok v :: _ -> Ok v
    | Error _ :: rest -> loop rest
  in
  loop results

let sequence = all

let tap f r =
  (match r with Ok v -> f v | Error _ -> ());
  r

let tap_error f r =
  (match r with Error e -> f e | Ok _ -> ());
  r
