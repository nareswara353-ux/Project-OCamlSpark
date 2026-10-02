open Trajectory_types
open Telemetry

let mk_snapshot ts defl =
  { timestamp = ts;
    mode = AutoPilot;
    deflection = defl;
    rate_limit = 0.1;
    position = defl *. 2.0;
    velocity = 0.0;
    is_safe = true }

let test_empty () =
  let t = create () in
  Alcotest.(check int) "empty count" 0 (count t);
  Alcotest.(check bool) "no latest" true (latest t = None);
  Alcotest.(check int) "no history" 0 (List.length (history t))

let test_record_and_latest () =
  let t = create () in
  record t (mk_snapshot 1.0 0.5);
  record t (mk_snapshot 2.0 0.6);
  record t (mk_snapshot 3.0 0.7);
  Alcotest.(check int) "count 3" 3 (count t);
  match latest t with
  | Some snap -> Alcotest.(check (float 0.001)) "latest timestamp" 3.0 snap.timestamp
  | None -> Alcotest.fail "expected latest"

let test_history_order () =
  let t = create () in
  record t (mk_snapshot 1.0 0.1);
  record t (mk_snapshot 2.0 0.2);
  record t (mk_snapshot 3.0 0.3);
  let h = history t in
  Alcotest.(check int) "history length" 3 (List.length h);
  let timestamps = List.map (fun s -> s.timestamp) h in
  Alcotest.(check bool) "chronological" true (timestamps = [1.0; 2.0; 3.0])

let test_clear () =
  let t = create () in
  record t (mk_snapshot 1.0 0.5);
  clear t;
  Alcotest.(check int) "cleared" 0 (count t)

let test_snapshot_of_state () =
  let state = { position = 1.5; velocity = 0.3; acceleration = 0.0; timestamp = 5.0 } in
  let cmd = { deflection = 0.6; rate_limit = 0.2 } in
  let snap = snapshot_of_state 5.0 Manual cmd state true in
  Alcotest.(check (float 0.001)) "deflection" 0.6 snap.deflection;
  Alcotest.(check (float 0.001)) "position" 1.5 snap.position;
  Alcotest.(check bool) "mode" true (snap.mode = Manual);
  Alcotest.(check bool) "safe" true snap.is_safe

let () =
  Alcotest.run "Telemetry" [
    "empty", [ Alcotest.test_case "initial" `Quick test_empty ];
    "record", [ Alcotest.test_case "latest" `Quick test_record_and_latest ];
    "history", [ Alcotest.test_case "ordered" `Quick test_history_order ];
    "clear", [ Alcotest.test_case "reset" `Quick test_clear ];
    "snapshot", [ Alcotest.test_case "from state" `Quick test_snapshot_of_state ];
  ]
