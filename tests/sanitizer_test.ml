open Trajectory_types
open Sanitizer

let test_sanitize_float_nan () =
  Alcotest.(check (float 0.001)) "NaN replaced" 1.0
    (sanitize_float ~default:1.0 Float.nan)

let test_sanitize_float_inf () =
  Alcotest.(check (float 0.001)) "Inf replaced" 5.0
    (sanitize_float ~default:5.0 Float.infinity);
  Alcotest.(check (float 0.001)) "-Inf replaced" 5.0
    (sanitize_float ~default:5.0 Float.neg_infinity)

let test_sanitize_float_valid () =
  Alcotest.(check (float 0.001)) "unchanged" 3.14
    (sanitize_float ~default:0.0 3.14)

let test_clamp () =
  Alcotest.(check (float 0.001)) "below" 0.0 (clamp (-1.0) 0.0 1.0);
  Alcotest.(check (float 0.001)) "above" 1.0 (clamp 2.0 0.0 1.0);
  Alcotest.(check (float 0.001)) "in range" 0.5 (clamp 0.5 0.0 1.0);
  Alcotest.(check (float 0.001)) "NaN to lo" 0.0 (clamp Float.nan 0.0 1.0)

let test_normalize_rate () =
  Alcotest.(check (float 0.001)) "negative" 0.0 (normalize_rate (-0.5));
  Alcotest.(check (float 0.001)) "above 1" 1.0 (normalize_rate 1.5);
  Alcotest.(check (float 0.001)) "valid" 0.5 (normalize_rate 0.5);
  Alcotest.(check (float 0.001)) "NaN" 0.0 (normalize_rate Float.nan)

let test_sanitize_command () =
  let cmd = { deflection = 1.5; rate_limit = 2.0 } in
  let clean = sanitize_command cmd 0.9 (-0.9) in
  Alcotest.(check (float 0.001)) "clamped deflection" 0.9 clean.deflection;
  Alcotest.(check (float 0.001)) "rate normalized" 1.0 clean.rate_limit

let test_sanitize_waypoint () =
  let wp = {
    target_position = Float.nan;
    target_velocity = Float.infinity;
    time_to_reach = -1.0
  } in
  let clean = sanitize_waypoint wp in
  Alcotest.(check (float 0.001)) "pos default" 0.0 clean.target_position;
  Alcotest.(check (float 0.001)) "vel default" 0.0 clean.target_velocity;
  Alcotest.(check bool) "time positive" true (clean.time_to_reach > 0.0)

let test_sanitize_state () =
  let s = {
    position = Float.nan;
    velocity = Float.infinity;
    acceleration = Float.nan;
    timestamp = 1.0
  } in
  let clean = sanitize_state s in
  Alcotest.(check (float 0.001)) "pos" 0.0 clean.position;
  Alcotest.(check (float 0.001)) "vel" 0.0 clean.velocity;
  Alcotest.(check (float 0.001)) "acc" 0.0 clean.acceleration;
  Alcotest.(check (float 0.001)) "ts preserved" 1.0 clean.timestamp

let () =
  Alcotest.run "Sanitizer" [
    "nan", [ Alcotest.test_case "replace NaN" `Quick test_sanitize_float_nan ];
    "inf", [ Alcotest.test_case "replace Inf" `Quick test_sanitize_float_inf ];
    "valid", [ Alcotest.test_case "unchanged" `Quick test_sanitize_float_valid ];
    "clamp", [ Alcotest.test_case "bounds" `Quick test_clamp ];
    "normalize_rate", [ Alcotest.test_case "rate limits" `Quick test_normalize_rate ];
    "command", [ Alcotest.test_case "sanitize" `Quick test_sanitize_command ];
    "waypoint", [ Alcotest.test_case "sanitize" `Quick test_sanitize_waypoint ];
    "state", [ Alcotest.test_case "sanitize" `Quick test_sanitize_state ];
  ]
