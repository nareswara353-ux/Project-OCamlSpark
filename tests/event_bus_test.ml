open Event_bus

let test_subscribe_publish () =
  let bus = create () in
  let received = ref [] in
  let _sub = subscribe bus "test_topic" (fun (v : int) -> received := v :: !received) in
  publish bus "test_topic" 42;
  publish bus "test_topic" 43;
  Alcotest.(check int) "two messages" 2 (List.length !received);
  Alcotest.(check int) "latest first" 43 (List.hd !received)

let test_unsubscribe () =
  let bus = create () in
  let count = ref 0 in
  let sub = subscribe bus "x" (fun (_ : int) -> incr count) in
  publish bus "x" 1;
  unsubscribe bus sub;
  publish bus "x" 2;
  Alcotest.(check int) "only one call" 1 !count

let test_topic_isolation () =
  let bus = create () in
  let a = ref 0 and b = ref 0 in
  let _sa = subscribe bus "topicA" (fun (_ : int) -> incr a) in
  let _sb = subscribe bus "topicB" (fun (_ : int) -> incr b) in
  publish bus "topicA" 1;
  publish bus "topicB" 1;
  publish bus "topicA" 1;
  Alcotest.(check int) "topic A twice" 2 !a;
  Alcotest.(check int) "topic B once" 1 !b

let test_subscriber_count () =
  let bus = create () in
  Alcotest.(check int) "empty" 0 (subscriber_count bus "t");
  let _s1 = subscribe bus "t" (fun (_ : int) -> ()) in
  let _s2 = subscribe bus "t" (fun (_ : int) -> ()) in
  Alcotest.(check int) "two" 2 (subscriber_count bus "t")

let test_clear () =
  let bus = create () in
  let _s = subscribe bus "t" (fun (_ : int) -> ()) in
  clear bus;
  Alcotest.(check int) "cleared" 0 (subscriber_count bus "t")

let test_publish_no_subscriber () =
  let bus = create () in
  publish bus "unknown" 99;
  Alcotest.(check bool) "no crash" true true

let () =
  Alcotest.run "Event_bus" [
    "subscribe", [ Alcotest.test_case "publish delivers" `Quick test_subscribe_publish ];
    "unsubscribe", [ Alcotest.test_case "stops delivery" `Quick test_unsubscribe ];
    "isolation", [ Alcotest.test_case "topics separate" `Quick test_topic_isolation ];
    "count", [ Alcotest.test_case "subscriber count" `Quick test_subscriber_count ];
    "clear", [ Alcotest.test_case "clear removes all" `Quick test_clear ];
    "empty", [ Alcotest.test_case "no-op" `Quick test_publish_no_subscriber ];
  ]
