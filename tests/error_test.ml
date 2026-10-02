open Error

let test_constructors () =
  let e = validation "V001" "bad input" in
  Alcotest.(check bool) "category validation" true (e.category = Validation);
  Alcotest.(check string) "code" "V001" e.code;
  Alcotest.(check string) "message" "bad input" e.message

let test_to_string () =
  let e = actuator "A001" "stuck" in
  let s = to_string e in
  Alcotest.(check bool) "contains category" true
    (try ignore (Str.search_forward (Str.regexp_string "ACTUATOR") s 0); true
     with Not_found -> false)

let test_bind_ok () =
  let r = Ok 5 in
  let result = bind r (fun x -> Ok (x * 2)) in
  Alcotest.(check bool) "bind ok" true (result = Ok 10)

let test_bind_error () =
  let e = validation "V001" "err" in
  let r : (int, t) result = Error e in
  let result = bind r (fun x -> Ok (x * 2)) in
  Alcotest.(check bool) "bind error preserves" true (result = Error e)

let test_map () =
  let r = Ok 3 in
  let result = map (fun x -> x + 1) r in
  Alcotest.(check bool) "map ok" true (result = Ok 4)

let test_let_star () =
  let result =
    let* x = Ok 5 in
    let* y = Ok 10 in
    Ok (x + y)
  in
  Alcotest.(check bool) "let* composes" true (result = Ok 15)

let test_let_plus () =
  let result = let+ x = Ok 5 in x * 2 in
  Alcotest.(check bool) "let+ maps" true (result = Ok 10)

let () =
  Alcotest.run "Error" [
    "constructors", [ Alcotest.test_case "validation" `Quick test_constructors ];
    "to_string", [ Alcotest.test_case "formats" `Quick test_to_string ];
    "bind", [
      Alcotest.test_case "ok" `Quick test_bind_ok;
      Alcotest.test_case "error" `Quick test_bind_error;
    ];
    "map", [ Alcotest.test_case "map" `Quick test_map ];
    "let_star", [ Alcotest.test_case "compose" `Quick test_let_star ];
    "let_plus", [ Alcotest.test_case "map" `Quick test_let_plus ];
  ]
