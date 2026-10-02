open Config

let test_default () =
  let cfg = default in
  Alcotest.(check (float 0.001)) "control freq" 20.0 cfg.control_freq_hz;
  Alcotest.(check (float 0.001)) "max def" 0.95 cfg.max_deflection;
  Alcotest.(check (float 0.001)) "min def" (-0.95) cfg.min_deflection

let test_validate_ok () =
  match validate default with
  | Ok _ -> Alcotest.(check bool) "valid" true true
  | Error msg -> Alcotest.fail ("unexpected error: " ^ msg)

let test_validate_bad_freq () =
  let cfg = { default with control_freq_hz = -1.0 } in
  match validate cfg with
  | Ok _ -> Alcotest.fail "expected error"
  | Error msg -> Alcotest.(check bool) "rejected" true (String.length msg > 0)

let test_validate_bad_limits () =
  let cfg = { default with max_deflection = 0.5; min_deflection = 0.8 } in
  match validate cfg with
  | Ok _ -> Alcotest.fail "expected error"
  | Error _ -> Alcotest.(check bool) "rejected" true true

let test_validate_out_of_range () =
  let cfg = { default with max_deflection = 1.5 } in
  match validate cfg with
  | Ok _ -> Alcotest.fail "expected error"
  | Error _ -> Alcotest.(check bool) "rejected" true true

let test_validate_bad_timeout () =
  let cfg = { default with sensor_timeout_s = 0.0 } in
  match validate cfg with
  | Ok _ -> Alcotest.fail "expected error"
  | Error _ -> Alcotest.(check bool) "rejected" true true

let test_with_control_freq () =
  let cfg = with_control_freq default 50.0 in
  Alcotest.(check (float 0.001)) "updated" 50.0 cfg.control_freq_hz

let test_with_limits () =
  let cfg = with_limits default 0.8 (-0.8) in
  Alcotest.(check (float 0.001)) "max" 0.8 cfg.max_deflection;
  Alcotest.(check (float 0.001)) "min" (-0.8) cfg.min_deflection

let test_get_limits () =
  let max_d, min_d = get_limits default in
  Alcotest.(check (float 0.001)) "max" 0.95 max_d;
  Alcotest.(check (float 0.001)) "min" (-0.95) min_d

let () =
  Alcotest.run "Config" [
    "default", [ Alcotest.test_case "sane values" `Quick test_default ];
    "validate_ok", [ Alcotest.test_case "default passes" `Quick test_validate_ok ];
    "validate_freq", [ Alcotest.test_case "negative freq" `Quick test_validate_bad_freq ];
    "validate_limits", [ Alcotest.test_case "inverted limits" `Quick test_validate_bad_limits ];
    "validate_range", [ Alcotest.test_case "out of range" `Quick test_validate_out_of_range ];
    "validate_timeout", [ Alcotest.test_case "zero timeout" `Quick test_validate_bad_timeout ];
    "with_freq", [ Alcotest.test_case "builder" `Quick test_with_control_freq ];
    "with_limits", [ Alcotest.test_case "builder" `Quick test_with_limits ];
    "get_limits", [ Alcotest.test_case "extract" `Quick test_get_limits ];
  ]
