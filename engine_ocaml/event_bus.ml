type topic = string
type 'a handler = 'a -> unit

type subscription = {
  topic : topic;
  id : int;
}

type t = {
  handlers : (topic, (int * (Obj.t -> unit)) list ref) Hashtbl.t;
  mutable next_id : int;
}

let create () = {
  handlers = Hashtbl.create 16;
  next_id = 0;
}

let subscribe t topic (handler : 'a handler) : subscription =
  let wrapped = fun (obj : Obj.t) -> handler (Obj.obj obj : 'a) in
  let id = t.next_id in
  t.next_id <- t.next_id + 1;
  let existing =
    match Hashtbl.find_opt t.handlers topic with
    | Some ref_list -> ref_list
    | None ->
        let r = ref [] in
        Hashtbl.add t.handlers topic r;
        r
  in
  existing := (id, wrapped) :: !existing;
  { topic; id }

let unsubscribe t (sub : subscription) =
  match Hashtbl.find_opt t.handlers sub.topic with
  | None -> ()
  | Some ref_list ->
      ref_list := List.filter (fun (id, _) -> id <> sub.id) !ref_list

let publish t topic (value : 'a) =
  match Hashtbl.find_opt t.handlers topic with
  | None -> ()
  | Some ref_list ->
      let handlers = List.rev !ref_list in
      List.iter (fun (_, h) -> h (Obj.repr value)) handlers

let clear t =
  Hashtbl.clear t.handlers

let subscriber_count t topic =
  match Hashtbl.find_opt t.handlers topic with
  | None -> 0
  | Some ref_list -> List.length !ref_list
