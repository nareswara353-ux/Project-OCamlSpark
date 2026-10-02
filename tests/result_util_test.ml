open Result_util

let test_predicates () =
  Alcotest.(check bool) "Ok is_ok" true (is_ok (Ok 1));
  Alcotest.(check bool) "Error is_ok" false (is_ok (Error "e"));
  Alcotest.(check bool) "Error is_error" true (is_error (Error "e"));
  Alcotest.(check bool) "Ok is_error" false (is_error (Ok 1))

let test_get_or_default () =
  Alcotest.(check int) "ok" 5 (get_or_default ~default:0 (Ok 5));
  Alcotest.(check int) "error" 0 (get_or_default ~default:0 (Error "e"))

let test_to_option () =
  Alcotest.(check bool) "ok->some" true (to_option (Ok 5) = Some 5);
  Alcotest.(check bool) "error->none" true (to_option (Error "e") = None)

let test_of_option () =
  Alcotest.(check bool) "some->ok" true (of_option ~error:"e" (Some 5) = Ok 5);
  Alcotest.(check bool) "none->error" true (of_option ~error:"e" None = Error "e")

let test_map_error () =
  let r : (int, string) result = Error "e" in
  let r' = map_error String.length r in
  Alcotest.(check bool) "mapped" true (r' = Error 1)

let test_all () =
  Alcotest.(check bool) "all ok" true (all [Ok 1; Ok 2; Ok 3] = Ok [1; 2; 3]);
  Alcotest.(check bool) "one err" true (all [Ok 1; Error "e"; Ok 3] = Error "e")

let test_any () =
  Alcotest.(check bool) "first ok" true (any [Ok 1; Error "e"] = Ok 1);
  Alcotest.(check bool) "skip errors" true (any [Error "a"; Ok 2] = Ok 2)

let test_tap () =
  let captured = ref 0 in
  let r = Ok 5 in
  let _ = tap (fun v -> captured := v) r in
  Alcotest.(check int) "tap called" 5 !captured

let () =
  Alcotest.run "Result_util" [
    "predicates", [ Alcotest.test_case "is_ok/is_error" `Quick test_predicates ];
    "get_or_default", [ Alcotest.test_case "default" `Quick test_get_or_default ];
    "to_option", [ Alcotest.test_case "to option" `Quick test_to_option ];
    "of_option", [ Alcotest.test_case "of option" `Quick test_of_option ];
    "map_error", [ Alcotest.test_case "map error" `Quick test_map_error ];
    "all", [ Alcotest.test_case "aggregate" `Quick test_all ];
    "any", [ Alcotest.test_case "first ok" `Quick test_any ];
    "tap", [ Alcotest.test_case "side effect" `Quick test_tap ];
  ]
