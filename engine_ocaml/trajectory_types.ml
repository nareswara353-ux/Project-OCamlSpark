type waypoint = {
  x : float;
  y : float;
  z : float;
  time : float;
}

type state = {
  position : waypoint;
  velocity : float * float * float;
  attitude : float * float * float;
}

type trajectory = {
  waypoints : waypoint list;
  duration : float;
  max_speed : float;
  max_accel : float;
}

let create_waypoint x y z time = { x; y; z; time }

let create_state pos vel att = { position = pos; velocity = vel; attitude = att }

let create_trajectory wps dur max_spd max_acc = {
  waypoints = wps;
  duration = dur;
  max_speed = max_spd;
  max_accel = max_acc;
}
