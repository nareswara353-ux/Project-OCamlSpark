open Time_util

let test_now () =
  let t = now () in
  Alcotest.(check bool) "now positive" true (t > 0.0)

let test_diff () =
  Alcotest.(check (float 0.0001)) "diff" 5.0 (diff 10.0 5.0)

let test_add_seconds () =
  Alcotest.(check (float 0.0001)) "add" 15.0 (add_seconds 10.0 5.0)

let test_is_expired () =
  Alcotest.(check bool) "expired" true (is_expired 100.0 150.0);
  Alcotest.(check bool) "not expired" false (is_expired 150.0 100.0)

let test_format_iso8601 () =
  let s = format_iso8601 0.0 in
  Alcotest.(check bool) "starts with 1970" true
    (String.length s >= 4 && String.sub s 0 4 = "1970");
  Alcotest.(check bool) "ends with Z" true
    (s.[String.length s - 1] = 'Z')

let test_format_duration () =
  Alcotest.(check bool) "milliseconds" true
    (String.length (format_duration 0.5) > 0);
  Alcotest.(check bool) "seconds" true
    (String.length (format_duration 5.0) > 0);
  Alcotest.(check bool) "minutes" true
    (String.length (format_duration 90.0) > 0)

let test_seconds_to_ms () =
  Alcotest.(check (float 0.0001)) "convert" 1500.0 (seconds_to_ms 1.5);
  Alcotest.(check (float 0.0001)) "reverse" 1.5 (ms_to_seconds 1500.0)

let test_sample_period () =
  let samples = sample_period 10.0 [] in
  Alcotest.(check bool) "non-empty" true (List.length samples > 0);
  let hd = List.hd samples in
  Alcotest.(check (float 0.0001)) "first at zero" 0.0 hd

let () =
  Alcotest.run "Time_util" [
    "now", [ Alcotest.test_case "positive" `Quick test_now ];
    "diff", [ Alcotest.test_case "subtract" `Quick test_diff ];
    "add", [ Alcotest.test_case "add_seconds" `Quick test_add_seconds ];
    "expired", [ Alcotest.test_case "is_expired" `Quick test_is_expired ];
    "iso8601", [ Alcotest.test_case "format" `Quick test_format_iso8601 ];
    "duration", [ Alcotest.test_case "format" `Quick test_format_duration ];
    "conversion", [ Alcotest.test_case "ms conversion" `Quick test_seconds_to_ms ];
    "sampling", [ Alcotest.test_case "period" `Quick test_sample_period ];
  ]
