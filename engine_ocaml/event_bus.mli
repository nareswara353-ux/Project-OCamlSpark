type topic = string
type 'a handler = 'a -> unit
type subscription

type t

val create : unit -> t
val subscribe : t -> topic -> 'a handler -> subscription
val unsubscribe : t -> subscription -> unit
val publish : t -> topic -> 'a -> unit
val clear : t -> unit
val subscriber_count : t -> topic -> int
