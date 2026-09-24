type 'a t = {
  data : 'a option array;
  capacity : int;
  mutable head : int;
  mutable tail : int;
  mutable count : int;
}

let create capacity =
  if capacity <= 0 then invalid_arg "ring_buffer: capacity must be positive";
  { data = Array.make capacity None;
    capacity;
    head = 0;
    tail = 0;
    count = 0 }

let capacity t = t.capacity
let length t = t.count
let is_empty t = t.count = 0
let is_full t = t.count = t.capacity

let push t v =
  t.data.(t.tail) <- Some v;
  t.tail <- (t.tail + 1) mod t.capacity;
  if t.count < t.capacity then
    t.count <- t.count + 1
  else
    t.head <- (t.head + 1) mod t.capacity

let pop t =
  if t.count = 0 then None
  else begin
    let v = t.data.(t.head) in
    t.data.(t.head) <- None;
    t.head <- (t.head + 1) mod t.capacity;
    t.count <- t.count - 1;
    v
  end

let peek t =
  if t.count = 0 then None
  else t.data.(t.head)

let clear t =
  Array.fill t.data 0 t.capacity None;
  t.head <- 0;
  t.tail <- 0;
  t.count <- 0

let to_list t =
  let rec loop i acc =
    if i >= t.count then List.rev acc
    else
      let idx = (t.head + i) mod t.capacity in
      match t.data.(idx) with
      | Some v -> loop (i + 1) (v :: acc)
      | None -> loop (i + 1) acc
  in
  loop 0 []

let iter f t =
  let rec loop i =
    if i >= t.count then ()
    else begin
      let idx = (t.head + i) mod t.capacity in
      (match t.data.(idx) with Some v -> f v | None -> ());
      loop (i + 1)
    end
  in
  loop 0

let fold f init t =
  let rec loop i acc =
    if i >= t.count then acc
    else
      let idx = (t.head + i) mod t.capacity in
      match t.data.(idx) with
      | Some v -> loop (i + 1) (f acc v)
      | None -> loop (i + 1) acc
  in
  loop 0 init
