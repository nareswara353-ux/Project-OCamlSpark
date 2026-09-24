type 'a t

val create : int -> 'a t
val capacity : 'a t -> int
val length : 'a t -> int
val is_empty : 'a t -> bool
val is_full : 'a t -> bool
val push : 'a t -> 'a -> unit
val pop : 'a t -> 'a option
val peek : 'a t -> 'a option
val clear : 'a t -> unit
val to_list : 'a t -> 'a list
val iter : ('a -> unit) -> 'a t -> unit
val fold : ('acc -> 'a -> 'acc) -> 'acc -> 'a t -> 'acc
