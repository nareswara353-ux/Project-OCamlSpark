# Architecture — Flight Control Surface Actuator Controller

## Overview
+---------------------+ +---------------------+ +---------------------+
| SPARK/Ada | | C FFI Layer | | OCaml Engine |
| Safety Kernel |<--->| (bindings/.c,.h) |<--->| (engine_ocaml/) |
+---------------------+ +---------------------+ +---------------------+
^ ^ ^
| | |
gnatprove pointer-based ABI Dune build
contracts Ctypes.double Alcotest

text

## Layer 1 — SPARK Safety Kernel (`core_spark/`)

| Unit | Responsibility |
|---|---|
| `Actuator_Types` | Tipe dasar: `Command`, `Limit_Record`, `Health_Status` |
| `Actuator_Commands` | Validate + apply limits dengan Pre/Post |
| `Redundancy_Voter` | Triple-redundant median voting |
| `Health_Monitor` | Aggregasi status sensor per channel |
| `Actuator_Limits` | Konstanta limit dan predikat safe |
| `Actuator_Controller` | FSM: Idle → Active → Fault/Emergency |
| `Power_Distribution` | Bus power allocation + load shedding |
| `Debug_Interface` | Read-only telemetry |
| `Spark_Exports` | C-ABI export via `pragma Export` |

## Layer 2 — C FFI (`bindings/`)

- `spark_export.h` — Deklarasi C untuk symbol SPARK
- `actuator_ffi.h/c` — Wrapper primitive + pointer-based struct
- `actuator_bridge.h/c` — Marshalling OCaml ↔ SPARK
- `ocaml_glue.h/c` — Callback untuk trajectory + mode
- `spark_stubs.c` — Implementasi stub untuk build lokal tanpa GNAT
- `actuator_binding.ml` — Binding OCaml via `Ctypes`

## Layer 3 — OCaml Engine (`engine_ocaml/`)

**Domain (6 modul)**
- `trajectory_types` — Tipe record + variant
- `optimizer` — Velocity/accel clamping
- `setpoint_gen` — Interpolasi linier
- `mode_manager` — Flight mode FSM
- `trajectory` — API level tinggi
- `fuser` — Kalman filter sederhana

**Utility (12 modul)**
- `logger`, `error`, `time_util`, `result_util`, `ring_buffer`
- `event_bus`, `telemetry`, `metrics`
- `config`, `config_loader`
- `validator`, `sanitizer`, `waypoint_parser`, `serializer`

## Data Flow
Waypoint text → waypoint_parser → validator → sanitizer
|
v
optimizer → setpoint_gen → actuator_command list
|
v
actuator_binding → FFI → SPARK controller
|
v
telemetry ← snapshot ← runtime state
|
v
metrics → export

text

## Configuration

Environment variables (prefix `ACTUATOR_`):
- `CONTROL_FREQ_HZ` (default 20.0)
- `MAX_DEFLECTION` / `MIN_DEFLECTION` (default ±0.95)
- `MAX_RATE_LIMIT` (default 0.5)
- `SENSOR_TIMEOUT_S` (default 0.5)
- `LOG_MIN_LEVEL` (default INFO)
- `TELEMETRY_CAPACITY` (default 1000)

## Testing Strategy

| Layer | Tool | Count |
|---|---|---|
| SPARK contracts | gnatprove | 30+ proof obligations |
| SPARK units | AUnit | 7 test cases |
| FFI binding | Alcotest | 4 test cases |
| OCaml utility | Alcotest | 17 test suites |
| Integration | Alcotest | 3 end-to-end scenarios |

## CI Pipeline

- **Push/PR** → stub-based build + 17 test suites (3–5 menit)
- **Nightly** → full SPARK proof + real library build (opsional)
- **Manual** → `workflow_dispatch` untuk proof on-demand

## Performance Budget

| Operation | Target | Benchmark |
|---|---|---|
| trajectory(100 waypoints) | < 5 ms | `bench/benchmark_runner.ml` |
| parse_lines(1000) | < 2 ms | `bench/benchmark_parser.ml` |
| FFI call overhead | < 100 ns | measured via `time_it` |