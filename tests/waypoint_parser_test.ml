open Trajectory_types
open Waypoint_parser

let test_parse_valid_line () =
  match parse_line "0.5,0.3,1.0" with
  | Ok wp ->
      Alcotest.(check (float 0.001)) "pos" 0.5 wp.target_position;
      Alcotest.(check (float 0.001)) "vel" 0.3 wp.target_velocity;
      Alcotest.(check (float 0.001)) "time" 1.0 wp.time_to_reach
  | Error e -> Alcotest.fail ("unexpected: " ^ Error.to_string e)

let test_parse_with_spaces () =
  match parse_line "  0.5 , 0.3 , 1.0  " with
  | Ok wp -> Alcotest.(check (float 0.001)) "pos" 0.5 wp.target_position
  | Error e -> Alcotest.fail ("unexpected: " ^ Error.to_string e)

let test_parse_empty () =
  match parse_line "" with
  | Ok _ -> Alcotest.fail "expected error"
  | Error _ -> Alcotest.(check bool) "rejected" true true

let test_parse_comment () =
  match parse_line "# comment" with
  | Ok _ -> Alcotest.fail "expected error"
  | Error _ -> Alcotest.(check bool) "rejected" true true

let test_parse_bad_float () =
  match parse_line "abc,0.3,1.0" with
  | Ok _ -> Alcotest.fail "expected error"
  | Error _ -> Alcotest.(check bool) "rejected" true true

let test_parse_missing_fields () =
  match parse_line "0.5,0.3" with
  | Ok _ -> Alcotest.fail "expected error"
  | Error _ -> Alcotest.(check bool) "rejected" true true

let test_parse_negative_time () =
  match parse_line "0.5,0.3,-1.0" with
  | Ok _ -> Alcotest.fail "expected error"
  | Error _ -> Alcotest.(check bool) "rejected" true true

let test_parse_lines () =
  let lines = [
    "# trajectory";
    "0.1,0.0,1.0";
    "";
    "0.2,0.1,2.0";
    "# end";
    "0.3,0.2,1.5"
  ] in
  match parse_lines lines with
  | Ok wps -> Alcotest.(check int) "3 waypoints" 3 (List.length wps)
  | Error e -> Alcotest.fail ("unexpected: " ^ Error.to_string e)

let test_parse_string () =
  let content = "0.5,0.3,1.0\n0.6,0.2,1.0" in
  match parse_string content with
  | Ok wps -> Alcotest.(check int) "2 waypoints" 2 (List.length wps)
  | Error e -> Alcotest.fail ("unexpected: " ^ Error.to_string e)

let test_render_line () =
  let wp = { target_position = 0.5; target_velocity = 0.3; time_to_reach = 1.0 } in
  let s = render_line wp in
  Alcotest.(check bool) "non-empty" true (String.length s > 0)

let test_round_trip () =
  let wp = { target_position = 0.75; target_velocity = 0.25; time_to_reach = 1.5 } in
  let rendered = render_line wp in
  match parse_line rendered with
  | Ok parsed ->
      Alcotest.(check (float 0.0001)) "pos roundtrip" wp.target_position parsed.target_position;
      Alcotest.(check (float 0.0001)) "vel roundtrip" wp.target_velocity parsed.target_velocity
  | Error e -> Alcotest.fail ("roundtrip failed: " ^ Error.to_string e)

let () =
  Alcotest.run "Waypoint_parser" [
    "valid", [ Alcotest.test_case "parse line" `Quick test_parse_valid_line ];
    "spaces", [ Alcotest.test_case "tolerant whitespace" `Quick test_parse_with_spaces ];
    "empty", [ Alcotest.test_case "empty rejected" `Quick test_parse_empty ];
    "comment", [ Alcotest.test_case "comment rejected" `Quick test_parse_comment ];
    "bad_float", [ Alcotest.test_case "invalid number" `Quick test_parse_bad_float ];
    "fields", [ Alcotest.test_case "missing fields" `Quick test_parse_missing_fields ];
    "neg_time", [ Alcotest.test_case "negative time" `Quick test_parse_negative_time ];
    "lines", [ Alcotest.test_case "batch parse" `Quick test_parse_lines ];
    "string", [ Alcotest.test_case "string parse" `Quick test_parse_string ];
    "render", [ Alcotest.test_case "render line" `Quick test_render_line ];
    "roundtrip", [ Alcotest.test_case "render then parse" `Quick test_round_trip ];
  ]
