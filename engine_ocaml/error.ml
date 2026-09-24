type category =
  | Validation
  | Actuator
  | Sensor
  | Power
  | Internal

type t = {
  category : category;
  code : string;
  message : string;
  context : (string * string) list;
}

let make category code message context =
  { category; code; message; context }

let validation code message = make Validation code message []
let actuator code message = make Actuator code message []
let sensor code message = make Sensor code message []
let power code message = make Power code message []
let internal code message = make Internal code message []

let category_to_string = function
  | Validation -> "VALIDATION"
  | Actuator -> "ACTUATOR"
  | Sensor -> "SENSOR"
  | Power -> "POWER"
  | Internal -> "INTERNAL"

let to_string e =
  let ctx =
    e.context
    |> List.map (fun (k, v) -> k ^ "=" ^ v)
    |> String.concat " "
  in
  if ctx = "" then
    Printf.sprintf "[%s:%s] %s" (category_to_string e.category) e.code e.message
  else
    Printf.sprintf "[%s:%s] %s (%s)"
      (category_to_string e.category) e.code e.message ctx

let bind r f =
  match r with
  | Ok v -> f v
  | Error e -> Error e

let map f r =
  match r with
  | Ok v -> Ok (f v)
  | Error e -> Error e

let ( let* ) = bind
let ( let+ ) r f = map f r
