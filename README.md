# Flight Control Surface Actuator Controller
## Hybrid Polyglot OCaml + SPARK (Ada) — High-Assurance Aerospace System

### Overview
Hybrid system untuk kontrol aktuator permukaan penerbangan dengan:
- **SPARK/Ada** (`core_spark/`): Komponen safety-critical terverifikasi formal (GNATprove)
- **OCaml** (`engine_ocaml/`): Engine fungsional + utility modules
- **C Glue** (`bindings/`): FFI dengan ABI pointer-based
- **Tests** (`tests/`): 17 test suite (Alcotest)
- **CI** (`.github/`): Stub-based pipeline (3–5 menit)

### Struktur Engine OCaml (20 modul)

**Core Domain**
- `trajectory_types` — tipe dasar (state, waypoint, command)
- `optimizer` — optimasi lintasan dengan velocity/accel clamping
- `setpoint_gen` — interpolasi linier antar waypoint
- `mode_manager` — FSM (Manual, AutoPilot, Emergency)
- `trajectory` — API level tinggi
- `fuser` — Kalman-style sensor fusion

**Utility**
- `logger` — structured logging (Debug/Info/Warn/Error)
- `error` — error terstruktur + monadic helpers (`let*`, `let+`)
- `time_util` — timestamps, ISO 8601, sampling
- `result_util` — combinators (`all`, `any`, `tap`)
- `ring_buffer` — circular buffer fixed-size

**Infrastructure**
- `event_bus` — pub-sub pattern
- `telemetry` — snapshot runtime (1000-cap)
- `metrics` — counter, gauge, histogram (p50/p99)
- `config` / `config_loader` — konfigurasi + env vars

**Validation**
- `validator` — validasi waypoint, trajectory, command
- `sanitizer` — NaN/Inf cleanup + clamping
- `waypoint_parser` — parser CSV-like
- `serializer` — pipe-delimited round-trip

### Build & Test

```bash
eval $(opam env)
dune build

make test-all            # semua 17 test
make test-validator      # test spesifik
make run                 # main.exe
Test Coverage (17 suites)
Suite	Coverage
ocaml_tests	optimizer, setpoint_gen, mode, FFI binding
integration_test	end-to-end FFI flow + emergency
fuser_test	Kalman init & fuse cycle
logger_test	level filter, context
error_test	constructors, monadic helpers
time_util_test	ISO 8601, durasi, sampling
result_util_test	all, any, tap, conversions
ring_buffer_test	FIFO, overwrite, fold
event_bus_test	subscribe, publish, isolation
telemetry_test	snapshot, history
metrics_test	counter, gauge, histogram
config_test	default, validate, builders
config_loader_test	KV parse, env merge
validator_test	waypoint/traj/command validation
sanitizer_test	NaN/Inf, clamp, rate normalize
waypoint_parser_test	parse, error, round-trip
serializer_test	state, command, trajectory round-trip
Konfigurasi via Environment
bash
export ACTUATOR_CONTROL_FREQ_HZ=50.0
export ACTUATOR_MAX_DEFLECTION=0.9
export ACTUATOR_LOG_MIN_LEVEL=DEBUG
Load dengan: Config_loader.load ()

FFI ABI Notes
Ctypes.double (8-byte) cocok C double

Struct argument di-pass via pointer (bukan by-value) untuk hindari ABI mismatch

-Wl,--export-dynamic untuk ctypes symbol resolution

SPARK Proof (Manual)
bash
gprbuild -P spark_lib.gpr -p
gnatprove -P actuator_controller.gpr --level=1
License
GPL-3.0-only