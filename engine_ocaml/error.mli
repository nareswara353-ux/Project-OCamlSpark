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

val make : category -> string -> string -> (string * string) list -> t
val validation : string -> string -> t
val actuator : string -> string -> t
val sensor : string -> string -> t
val power : string -> string -> t
val internal : string -> string -> t

val category_to_string : category -> string
val to_string : t -> string

val ( let* ) : ('a, t) result -> ('a -> ('b, t) result) -> ('b, t) result
val ( let+ ) : ('a, t) result -> ('a -> 'b) -> ('b, t) result
val map : ('a -> 'b) -> ('a, t) result -> ('b, t) result
val bind : ('a, t) result -> ('a -> ('b, t) result) -> ('b, t) result
