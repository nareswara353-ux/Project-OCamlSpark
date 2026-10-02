open Config_loader
open Config

let test_parse_kv_line () =
  Alcotest.(check bool) "simple" true (parse_kv_line "a=b" = Some ("a", "b"));
  Alcotest.(check bool) "with spaces" true
    (parse_kv_line "  key  =  value  " = Some ("key", "value"));
  Alcotest.(check bool) "no eq" true (parse_kv_line "noequals" = None);
  Alcotest.(check bool) "empty key" true (parse_kv_line "=v" = None)

let test_from_kv_list_control_freq () =
  let cfg = from_kv_list [("control_freq_hz", "50.0")] in
  Alcotest.(check (float 0.001)) "freq updated" 50.0 cfg.control_freq_hz

let test_from_kv_list_limits () =
  let cfg = from_kv_list [("max_deflection", "0.7"); ("min_deflection", "-0.7")] in
  Alcotest.(check (float 0.001)) "max" 0.7 cfg.max_deflection;
  Alcotest.(check (float 0.001)) "min" (-0.7) cfg.min_deflection

let test_from_kv_list_invalid () =
  let cfg = from_kv_list [("control_freq_hz", "not_a_number")] in
  Alcotest.(check (float 0.001)) "unchanged" 20.0 cfg.control_freq_hz

let test_load_valid () =
  match load ~env:false ~kv:[("control_freq_hz", "30.0")] () with
  | Ok cfg -> Alcotest.(check (float 0.001)) "loaded freq" 30.0 cfg.control_freq_hz
  | Error msg -> Alcotest.fail ("unexpected error: " ^ msg)

let test_load_invalid () =
  match load ~env:false ~kv:[("control_freq_hz", "-5.0")] () with
  | Ok _ -> Alcotest.fail "expected error"
  | Error _ -> Alcotest.(check bool) "rejected" true true

let test_load_telemetry () =
  match load ~env:false ~kv:[("telemetry_capacity", "500")] () with
  | Ok cfg -> Alcotest.(check int) "capacity" 500 cfg.telemetry_capacity
  | Error msg -> Alcotest.fail ("unexpected error: " ^ msg)

let () =
  Alcotest.run "Config_loader" [
    "parse_kv_line", [ Alcotest.test_case "format" `Quick test_parse_kv_line ];
    "from_kv_freq", [ Alcotest.test_case "freq" `Quick test_from_kv_list_control_freq ];
    "from_kv_limits", [ Alcotest.test_case "limits" `Quick test_from_kv_list_limits ];
    "from_kv_invalid", [ Alcotest.test_case "invalid preserves" `Quick test_from_kv_list_invalid ];
    "load_ok", [ Alcotest.test_case "valid load" `Quick test_load_valid ];
    "load_err", [ Alcotest.test_case "invalid load" `Quick test_load_invalid ];
    "load_telemetry", [ Alcotest.test_case "int field" `Quick test_load_telemetry ];
  ]
