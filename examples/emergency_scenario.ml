open Trajectory_types
open Mode_manager
open Telemetry
open Metrics
open Logger

let () =
  let log = Logger.create ~min_level:Info () in
  let telem = Telemetry.create () in
  let metrics = Metrics.create () in

  Logger.info log "emergency" "Initializing mode manager" [];
  let state = initial_mode_state in

  let cmd_normal = { deflection = 0.5; rate_limit = 0.1 } in
  let state_auto = transition state AutoPilot false in
  let processed_auto, _ = process_command state_auto cmd_normal in
  Metrics.incr metrics "commands_processed";
  Logger.info log "emergency"
    (Printf.sprintf "AutoPilot cmd: deflection=%.3f" processed_auto.deflection) [];

  let snap_auto = Telemetry.snapshot_of_state 1.0 AutoPilot processed_auto
      { position = 0.5; velocity = 0.0; acceleration = 0.0; timestamp = 1.0 } true in
  Telemetry.record telem snap_auto;

  Logger.warn log "emergency" "Triggering emergency override" [];
  let emergency_cmd, state_emerg = emergency_override_command state_auto 0.0 in
  Metrics.incr metrics "emergency_triggers";
  Logger.info log "emergency"
    (Printf.sprintf "Emergency cmd: deflection=%.3f rate=%.3f"
       emergency_cmd.deflection emergency_cmd.rate_limit) [];

  let snap_emerg = Telemetry.snapshot_of_state 2.0 Emergency emergency_cmd
      { position = 0.0; velocity = 0.0; acceleration = 0.0; timestamp = 2.0 } false in
  Telemetry.record telem snap_emerg;

  let is_emerg = is_emergency_active state_emerg in
  Logger.info log "emergency"
    (Printf.sprintf "Emergency active: %b" is_emerg) [];

  Metrics.observe metrics "latency_ms" 1.5;
  Metrics.observe metrics "latency_ms" 2.3;
  Metrics.observe metrics "latency_ms" 1.8;

  Logger.info log "emergency"
    (Printf.sprintf "Telemetry snapshots: %d" (Telemetry.count telem)) [];
  Logger.info log "emergency"
    (Printf.sprintf "Commands processed: %.0f" (Metrics.get_counter metrics "commands_processed")) [];

  (match Metrics.get_histogram metrics "latency_ms" with
   | Some h -> Logger.info log "emergency"
                 (Printf.sprintf "Latency: mean=%.2f p50=%.2f p99=%.2f"
                    h.mean h.p50 h.p99) []
   | None -> ());

  Logger.info log "emergency" "Scenario complete" []
