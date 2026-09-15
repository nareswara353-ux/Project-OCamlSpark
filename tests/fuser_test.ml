open Trajectory_types
open Fuser

let test_init () =
  let s = { position = 1.0; velocity = 0.5; acceleration = 0.1; timestamp = 0.0 } in
  let fs = initial_fusion_state s in
  Alcotest.(check (float 0.001)) "init pos" 1.0 (get_position fs);
  Alcotest.(check (float 0.001)) "init vel" 0.5 (get_velocity fs)

let test_fuse () =
  let s = { position = 0.0; velocity = 0.0; acceleration = 0.0; timestamp = 0.0 } in
  let fs = initial_fusion_state s in
  let packet = {
    imu = { accel_x = 0.1; accel_y = 0.0; accel_z = 0.0; timestamp = 0.1 };
    pitot = { airspeed = 0.5; altitude = 0.05; timestamp = 0.1 };
    gyro = { roll_rate = 0.0; pitch_rate = 0.0; yaw_rate = 0.0; timestamp = 0.1 };
  } in
  let out, _ = fuse_packet fs packet in
  Alcotest.(check bool) "output pos finite" true (Float.is_finite out.position);
  Alcotest.(check bool) "output vel finite" true (Float.is_finite out.velocity)

let () =
  Alcotest.run "Fuser" [
    "init", [ Alcotest.test_case "initial state" `Quick test_init ];
    "fuse", [ Alcotest.test_case "single fuse cycle" `Quick test_fuse ];
  ]
