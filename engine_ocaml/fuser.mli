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

type fusion_state

val initial_fusion_state : state -> fusion_state
val fuse_packet : fusion_state -> sensor_packet -> state * fusion_state
val get_position : fusion_state -> float
val get_velocity : fusion_state -> float
val get_acceleration : fusion_state -> float
val reset : state -> fusion_state
val is_converged : fusion_state -> bool
