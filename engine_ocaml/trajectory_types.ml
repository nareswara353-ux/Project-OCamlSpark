type state = {
  position : float;
  velocity : float;
  acceleration : float;
  timestamp : float;
}

type waypoint = {
  target_position : float;
  target_velocity : float;
  time_to_reach : float;
}

type trajectory = {
  waypoints : waypoint list;
  start_state : state;
  duration : float;
}

type actuator_command = {
  deflection : float;
  rate_limit : float;
}

type flight_mode =
  | Manual
  | AutoPilot
  | Emergency

type trajectory_parameters = {
  max_accel : float;
  max_velocity : float;
  jerk_limit : float;
}
