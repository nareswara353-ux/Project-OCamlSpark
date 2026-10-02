open Metrics

let test_counter_incr () =
  let m = create () in
  incr m "requests";
  incr m "requests";
  incr m "requests";
  Alcotest.(check (float 0.001)) "count 3" 3.0 (get_counter m "requests")

let test_counter_add () =
  let m = create () in
  add m "bytes" 100.0;
  add m "bytes" 250.0;
  Alcotest.(check (float 0.001)) "sum 350" 350.0 (get_counter m "bytes")

let test_counter_missing () =
  let m = create () in
  Alcotest.(check (float 0.001)) "default zero" 0.0 (get_counter m "unknown")

let test_gauge () =
  let m = create () in
  set_gauge m "temperature" 22.5;
  Alcotest.(check (float 0.001)) "value" 22.5 (get_gauge m "temperature");
  set_gauge m "temperature" 23.0;
  Alcotest.(check (float 0.001)) "updated" 23.0 (get_gauge m "temperature")

let test_histogram () =
  let m = create () in
  List.iter (fun v -> observe m "latency" v) [1.0; 2.0; 3.0; 4.0; 5.0];
  match get_histogram m "latency" with
  | Some h ->
      Alcotest.(check int) "count 5" 5 h.count;
      Alcotest.(check (float 0.001)) "min" 1.0 h.min;
      Alcotest.(check (float 0.001)) "max" 5.0 h.max;
      Alcotest.(check (float 0.001)) "mean" 3.0 h.mean
  | None -> Alcotest.fail "expected histogram"

let test_histogram_empty () =
  let m = create () in
  Alcotest.(check bool) "none" true (get_histogram m "unknown" = None)

let test_snapshot () =
  let m = create () in
  incr m "a";
  set_gauge m "b" 42.0;
  let snap = snapshot m in
  Alcotest.(check bool) "nonempty" true (List.length snap >= 2)

let test_reset () =
  let m = create () in
  incr m "x";
  set_gauge m "y" 5.0;
  reset m;
  Alcotest.(check (float 0.001)) "counter reset" 0.0 (get_counter m "x");
  Alcotest.(check (float 0.001)) "gauge reset" 0.0 (get_gauge m "y")

let () =
  Alcotest.run "Metrics" [
    "incr", [ Alcotest.test_case "counter" `Quick test_counter_incr ];
    "add", [ Alcotest.test_case "cumulative" `Quick test_counter_add ];
    "missing", [ Alcotest.test_case "default" `Quick test_counter_missing ];
    "gauge", [ Alcotest.test_case "set/update" `Quick test_gauge ];
    "histogram", [ Alcotest.test_case "stats" `Quick test_histogram ];
    "histogram_empty", [ Alcotest.test_case "no samples" `Quick test_histogram_empty ];
    "snapshot", [ Alcotest.test_case "list" `Quick test_snapshot ];
    "reset", [ Alcotest.test_case "clear" `Quick test_reset ];
  ]
