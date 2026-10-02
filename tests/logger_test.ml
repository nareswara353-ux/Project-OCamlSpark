let captured = ref []

let recording_sink entry =
  captured := entry :: !captured

let reset () = captured := []

let test_level_filter () =
  reset ();
  let l = Logger.create ~min_level:Logger.Warn ~sink:recording_sink () in
  Logger.debug l "test" "should be filtered" [];
  Logger.info l "test" "filtered too" [];
  Logger.warn l "test" "captured" [];
  Logger.error l "test" "captured too" [];
  Alcotest.(check int) "only warn+error captured" 2 (List.length !captured)

let test_context_in_entry () =
  reset ();
  let l = Logger.create ~min_level:Logger.Debug ~sink:recording_sink () in
  Logger.info l "mod" "msg" [("k1", "v1"); ("k2", "v2")];
  match !captured with
  | [entry] ->
      Alcotest.(check int) "context size" 2 (List.length entry.Logger.context);
      Alcotest.(check string) "module" "mod" entry.Logger.module_name
  | _ -> Alcotest.fail "expected exactly one captured entry"

let test_level_to_string () =
  Alcotest.(check string) "debug" "DEBUG" (Logger.level_to_string Logger.Debug);
  Alcotest.(check string) "info" "INFO" (Logger.level_to_string Logger.Info);
  Alcotest.(check string) "warn" "WARN" (Logger.level_to_string Logger.Warn);
  Alcotest.(check string) "error" "ERROR" (Logger.level_to_string Logger.Error)

let test_string_to_level () =
  Alcotest.(check bool) "DEBUG" true (Logger.string_to_level "DEBUG" = Logger.Debug);
  Alcotest.(check bool) "info" true (Logger.string_to_level "info" = Logger.Info);
  Alcotest.(check bool) "unknown defaults info" true
    (Logger.string_to_level "unknown" = Logger.Info)

let () =
  Alcotest.run "Logger" [
    "level_filter", [ Alcotest.test_case "filters below min" `Quick test_level_filter ];
    "context", [ Alcotest.test_case "context preserved" `Quick test_context_in_entry ];
    "level_to_string", [ Alcotest.test_case "level strings" `Quick test_level_to_string ];
    "string_to_level", [ Alcotest.test_case "parse level" `Quick test_string_to_level ];
  ]
