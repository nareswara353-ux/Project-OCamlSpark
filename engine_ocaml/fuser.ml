open Trajectory_types

type imu_reading = {
  accel_x : float;
  accel_y : float;
  accel_z : float;
  timestamp : float;
}

type pitot_reading = {
  airspeed : float;
  altitude : float;
  timestamp : float;
}

type gyro_reading = {
  roll_rate : float;
  pitch_rate : float;
  yaw_rate : float;
  timestamp : float;
}

type sensor_packet = {
  imu : imu_reading;
  pitot : pitot_reading;
  gyro : gyro_reading;
}

type fusion_state = {
  pos : float;
  vel : float;
  acc : float;
  pos_var : float;
  vel_var : float;
  acc_var : float;
  last_timestamp : float;
  sample_count : int;
}

let process_noise_pos = 0.01
let process_noise_vel = 0.05
let process_noise_acc = 0.1
let measurement_noise_pos = 0.5
let measurement_noise_vel = 0.2

let initial_fusion_state (s : state) : fusion_state = {
  pos = s.position;
  vel = s.velocity;
  acc = s.acceleration;
  pos_var = 1.0;
  vel_var = 1.0;
  acc_var = 1.0;
  last_timestamp = s.timestamp;
  sample_count = 0;
}

let reset (s : state) : fusion_state = initial_fusion_state s

let predict (fs : fusion_state) (dt : float) : fusion_state =
  let new_pos = fs.pos +. fs.vel *. dt +. 0.5 *. fs.acc *. dt *. dt in
  let new_vel = fs.vel +. fs.acc *. dt in
  let new_acc = fs.acc in
  let new_pos_var = fs.pos_var +. dt *. dt *. fs.vel_var +. process_noise_pos in
  let new_vel_var = fs.vel_var +. dt *. dt *. fs.acc_var +. process_noise_vel in
  let new_acc_var = fs.acc_var +. process_noise_acc in
  {
    pos = new_pos;
    vel = new_vel;
    acc = new_acc;
    pos_var = new_pos_var;
    vel_var = new_vel_var;
    acc_var = new_acc_var;
    last_timestamp = fs.last_timestamp +. dt;
    sample_count = fs.sample_count;
  }

let update_position (fs : fusion_state) (measured_pos : float) : fusion_state =
  let k = fs.pos_var /. (fs.pos_var +. measurement_noise_pos) in
  let new_pos = fs.pos +. k *. (measured_pos -. fs.pos) in
  let new_pos_var = (1.0 -. k) *. fs.pos_var in
  { fs with pos = new_pos; pos_var = new_pos_var }

let update_velocity (fs : fusion_state) (measured_vel : float) : fusion_state =
  let k = fs.vel_var /. (fs.vel_var +. measurement_noise_vel) in
  let new_vel = fs.vel +. k *. (measured_vel -. fs.vel) in
  let new_vel_var = (1.0 -. k) *. fs.vel_var in
  { fs with vel = new_vel; vel_var = new_vel_var }

let fuse_packet (fs : fusion_state) (packet : sensor_packet) : state * fusion_state =
  let dt = packet.imu.timestamp -. fs.last_timestamp in
  let dt = if dt <= 0.0 then 0.001 else dt in
  let predicted = predict fs dt in
  let accel_from_imu = packet.imu.accel_x in
  let vel_from_pitot = packet.pitot.airspeed in
  let pos_from_pitot = packet.pitot.altitude in
  let with_acc = { predicted with acc = accel_from_imu } in
  let with_vel = update_velocity with_acc vel_from_pitot in
  let with_pos = update_position with_vel pos_from_pitot in
  let final_state = { with_pos with sample_count = fs.sample_count + 1 } in
  let output = {
    position = final_state.pos;
    velocity = final_state.vel;
    acceleration = final_state.acc;
    timestamp = packet.imu.timestamp;
  } in
  (output, final_state)

let get_position (fs : fusion_state) : float = fs.pos
let get_velocity (fs : fusion_state) : float = fs.vel
let get_acceleration (fs : fusion_state) : float = fs.acc

let is_converged (fs : fusion_state) : bool =
  fs.pos_var < 0.05 && fs.vel_var < 0.05 && fs.sample_count >= 10
