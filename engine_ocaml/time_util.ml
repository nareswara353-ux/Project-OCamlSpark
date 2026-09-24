let now () = Unix.gettimeofday ()

let elapsed_since start = Unix.gettimeofday () -. start

let diff t1 t2 = t1 -. t2

let add_seconds t s = t +. s

let is_expired deadline current = current >= deadline

let format_iso8601 t =
  let tm = Unix.gmtime t in
  Printf.sprintf "%04d-%02d-%02dT%02d:%02d:%02dZ"
    (tm.Unix.tm_year + 1900)
    (tm.Unix.tm_mon + 1)
    tm.Unix.tm_mday
    tm.Unix.tm_hour
    tm.Unix.tm_min
    tm.Unix.tm_sec

let format_duration seconds =
  if seconds < 0.0 then Printf.sprintf "-%s" (format_duration (-. seconds))
  else if seconds < 1.0 then Printf.sprintf "%.2fms" (seconds *. 1000.0)
  else if seconds < 60.0 then Printf.sprintf "%.3fs" seconds
  else if seconds < 3600.0 then
    Printf.sprintf "%dm%.1fs" (int_of_float (seconds /. 60.0))
      (seconds -. (float_of_int (int_of_float (seconds /. 60.0)) *. 60.0))
  else
    Printf.sprintf "%dh%.1fm"
      (int_of_float (seconds /. 3600.0))
      ((seconds -. (float_of_int (int_of_float (seconds /. 3600.0)) *. 3600.0)) /. 60.0)

let seconds_to_ms s = s *. 1000.0
let ms_to_seconds ms = ms /. 1000.0

let sample_period freq start_times =
  if freq <= 0.0 then []
  else
    let period = 1.0 /. freq in
    let rec loop acc count =
      if count >= 10000 then List.rev acc
      else
        let t = period *. float_of_int count in
        if t > 3600.0 then List.rev acc
        else loop (t :: acc) (count + 1)
    in
    ignore start_times;
    loop [] 0
