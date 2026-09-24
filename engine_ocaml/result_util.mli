val is_ok : ('a, 'e) result -> bool
val is_error : ('a, 'e) result -> bool
val get_or_default : default:'a -> ('a, 'e) result -> 'a
val get_or_else : ('e -> 'a) -> ('a, 'e) result -> 'a
val to_option : ('a, 'e) result -> 'a option
val of_option : error:'e -> 'a option -> ('a, 'e) result
val map_error : ('e1 -> 'e2) -> ('a, 'e1) result -> ('a, 'e2) result
val all : ('a, 'e) result list -> ('a list, 'e) result
val any : ('a, 'e) result list -> ('a, 'e) result
val sequence : ('a, 'e) result list -> ('a list, 'e) result
val tap : ('a -> unit) -> ('a, 'e) result -> ('a, 'e) result
val tap_error : ('e -> unit) -> ('a, 'e) result -> ('a, 'e) result
