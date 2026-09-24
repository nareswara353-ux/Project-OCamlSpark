type histogram = {
  count : int;
  min : float;
  max : float;
  mean : float;
  p50 : float;
  p99 : float;
}

type t = {
  counters : (string, float) Hashtbl.t;
  gauges : (string, float) Hashtbl.t;
  samples : (string, float Ring_buffer.t) Hashtbl.t;
}

let create () = {
  counters = Hashtbl.create 16;
  gauges = Hashtbl.create 16;
  samples = Hashtbl.create 16;
}

let incr t name =
  let current = match Hashtbl.find_opt t.counters name with Some v -> v | None -> 0.0 in
  Hashtbl.replace t.counters name (current +. 1.0)

let add t name delta =
  let current = match Hashtbl.find_opt t.counters name with Some v -> v | None -> 0.0 in
  Hashtbl.replace t.counters name (current +. delta)

let set_gauge t name value =
  Hashtbl.replace t.gauges name value

let observe t name value =
  let buffer =
    match Hashtbl.find_opt t.samples name with
    | Some b -> b
    | None ->
        let b = Ring_buffer.create 1000 in
        Hashtbl.add t.samples name b;
        b
  in
  Ring_buffer.push buffer value

let get_counter t name =
  match Hashtbl.find_opt t.counters name with Some v -> v | None -> 0.0

let get_gauge t name =
  match Hashtbl.find_opt t.gauges name with Some v -> v | None -> 0.0

let percentile sorted p =
  let n = List.length sorted in
  if n = 0 then 0.0
  else
    let idx = int_of_float (float_of_int n *. p) in
    let idx = if idx >= n then n - 1 else idx in
    List.nth sorted idx

let get_histogram t name =
  match Hashtbl.find_opt t.samples name with
  | None -> None
  | Some buffer ->
      let values = Ring_buffer.to_list buffer in
      if values = [] then None
      else begin
        let sorted = List.sort compare values in
        let n = List.length values in
        let sum = List.fold_left ( +. ) 0.0 values in
        let mean = sum /. float_of_int n in
        let min_v = List.hd sorted in
        let max_v = List.nth sorted (n - 1) in
        Some {
          count = n;
          min = min_v;
          max = max_v;
          mean;
          p50 = percentile sorted 0.50;
          p99 = percentile sorted 0.99;
        }
      end

let snapshot t =
  let counters = Hashtbl.fold (fun k v acc -> (k ^ ":counter", v) :: acc) t.counters [] in
  let gauges = Hashtbl.fold (fun k v acc -> (k ^ ":gauge", v) :: acc) t.gauges [] in
  counters @ gauges

let reset t =
  Hashtbl.clear t.counters;
  Hashtbl.clear t.gauges;
  Hashtbl.clear t.samples
