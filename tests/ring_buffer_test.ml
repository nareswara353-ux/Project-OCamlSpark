open Ring_buffer

let test_create () =
  let b = create 5 in
  Alcotest.(check int) "capacity" 5 (capacity b);
  Alcotest.(check int) "empty length" 0 (length b);
  Alcotest.(check bool) "is_empty" true (is_empty b);
  Alcotest.(check bool) "not full" false (is_full b)

let test_push_pop () =
  let b = create 3 in
  push b 1; push b 2; push b 3;
  Alcotest.(check int) "length 3" 3 (length b);
  Alcotest.(check bool) "full" true (is_full b);
  Alcotest.(check bool) "pop 1" true (pop b = Some 1);
  Alcotest.(check bool) "pop 2" true (pop b = Some 2);
  Alcotest.(check int) "length 1" 1 (length b);
  Alcotest.(check bool) "pop 3" true (pop b = Some 3);
  Alcotest.(check bool) "empty pop" true (pop b = None)

let test_overwrite () =
  let b = create 2 in
  push b 1; push b 2; push b 3;
  Alcotest.(check int) "still length 2" 2 (length b);
  let items = to_list b in
  Alcotest.(check bool) "oldest dropped" true (items = [2; 3])

let test_to_list () =
  let b = create 5 in
  push b 10; push b 20; push b 30;
  Alcotest.(check bool) "list order" true (to_list b = [10; 20; 30])

let test_peek () =
  let b = create 3 in
  push b 42;
  Alcotest.(check bool) "peek" true (peek b = Some 42);
  Alcotest.(check int) "peek no pop" 1 (length b)

let test_clear () =
  let b = create 3 in
  push b 1; push b 2;
  clear b;
  Alcotest.(check int) "cleared" 0 (length b);
  Alcotest.(check bool) "empty after clear" true (is_empty b)

let test_iter () =
  let b = create 5 in
  push b 1; push b 2; push b 3;
  let sum = ref 0 in
  iter (fun v -> sum := !sum + v) b;
  Alcotest.(check int) "iter sum" 6 !sum

let test_fold () =
  let b = create 5 in
  push b 1; push b 2; push b 3;
  let total = fold (fun acc v -> acc + v) 0 b in
  Alcotest.(check int) "fold sum" 6 total

let test_invalid_capacity () =
  try
    let _ = create 0 in
    Alcotest.fail "expected exception"
  with Invalid_argument _ ->
    Alcotest.(check bool) "raised" true true

let () =
  Alcotest.run "Ring_buffer" [
    "create", [ Alcotest.test_case "empty" `Quick test_create ];
    "push_pop", [ Alcotest.test_case "FIFO" `Quick test_push_pop ];
    "overwrite", [ Alcotest.test_case "drop oldest" `Quick test_overwrite ];
    "to_list", [ Alcotest.test_case "ordered" `Quick test_to_list ];
    "peek", [ Alcotest.test_case "non-destructive" `Quick test_peek ];
    "clear", [ Alcotest.test_case "empties" `Quick test_clear ];
    "iter", [ Alcotest.test_case "sum" `Quick test_iter ];
    "fold", [ Alcotest.test_case "sum" `Quick test_fold ];
    "invalid", [ Alcotest.test_case "capacity 0" `Quick test_invalid_capacity ];
  ]
