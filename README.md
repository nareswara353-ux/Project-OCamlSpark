# Flight Control Surface Actuator Controller

Hybrid Polyglot OCaml + SPARK (Ada) — High-Assurance Aerospace System

---

## Overview

Proyek ini mengimplementasikan kontroler aktuator permukaan kendali penerbangan (aileron, elevator, rudder) dengan arsitektur hybrid:

- SPARK/Ada (core_spark/): Komponen safety-critical yang diverifikasi formal (GNATprove) — validasi perintah, voter redundansi triple, monitoring kesehatan, batas operasional, FSM controller, distribusi daya, dan antarmuka debug.

- OCaml (engine_ocaml/): Mesin optimasi lintasan fungsional, pembangkit setpoint, manajer mode terbang, dan FFI ke SPARK via C-ABI.

- C Glue Layer (bindings/): Marshalling tipe, wrapper, dan callback antara OCaml dan SPARK.

- Test Suite (tests/): AUnit untuk SPARK, Alcotest untuk OCaml, dan integration test end-to-end.

---

## Table of Contents

- [Arsitektur Folder](#arsitektur-folder)
- [Prerequisites](#prerequisites)
- [Build & Test](#build--test)
- [Formal Verification (SPARK)](#formal-verification-spark)
- [OCaml Design Principles](#ocaml-design-principles)
- [Contribution Guidelines](#contribution-guidelines)
- [Safety & Mission-Critical Assurance](#safety--mission-critical-assurance)
- [Future Extensions](#future-extensions)
- [License](#license)

---

## Arsitektur Folder

```
.
├── alire.toml                           # Alire manifest (GNAT/SPARK toolchain)
├── actuator_controller.gpr              # GNAT project (build & proof)
├── dune-project / dune / dune-workspace # Dune build configuration
├── .github/workflows/ci.yml             # CI pipeline (GitHub Actions)
│
├── core_spark/                          # SPARK units (25+ files)
│   ├── actuator_types.ads/adb
│   ├── actuator_commands.ads/adb
│   ├── redundancy_voter.ads/adb
│   ├── health_monitor.ads/adb
│   ├── actuator_limits.ads/adb
│   ├── actuator_pkg.ads
│   ├── debug_interface.ads/adb
│   ├── power_distribution.ads/adb
│   └── actuator_controller.ads/adb
│
├── bindings/                            # C FFI glue
│   ├── spark_export.h
│   ├── actuator_ffi.h / .c
│   ├── actuator_bridge.h / .c
│   └── ocaml_glue.h / .c
│
├── engine_ocaml/                        # OCaml functional engine
│   ├── trajectory_types.ml/i
│   ├── optimizer.ml/i
│   ├── setpoint_gen.ml/i
│   ├── mode_manager.ml/i
│   ├── trajectory.ml/i
│   └── dune
│
└── tests/                               # Test suites
    ├── spark_tests.ads/adb
    ├── ocaml_tests.ml/i
    └── integration_test.ml
```

---

## Prerequisites

Diperlukan:

- SPARK/Ada toolchain: Alire, GNAT, GNATprove
- OCaml: Opam, Dune (>= 3.12), libraries: ctypes-foreign, alcotest
- Build tools: gcc, make, git

---

## Build & Test

### Build SPARK (formal proof & compilation)

```bash
alr build
alr exec -- gnatprove -P actuator_controller.gpr --level=1 --timeout=60
```

### Build OCaml engine + FFI

```bash
dune build
```

### Run tests

```bash
# SPARK unit tests (AUnit)
alr exec -- ./obj/spark_tests

# OCaml unit tests (Alcotest)
dune exec -- tests/ocaml_tests.exe

# Integration tests
dune exec -- tests/integration_test.exe
```

### Full CI pipeline (GitHub Actions)

Push ke branch main akan memicu:

- Setup Alire & GNAT
- Proof with gnatprove
- Setup OCaml & Dune
- Build FFI + binary
- Run all test suites

---

## Formal Verification (SPARK)

Kontrak formal mencakup:

- Pre/Post conditions pada setiap fungsi
- Loop invariants (untuk iterasi)
- Type invariants (subtype Safe_Deflection, Safe_Command)
- Pragma Ghost untuk properti global

Proved properties: no overflow, no runtime error, valid range, consensus, safety envelope.

---

## OCaml Design Principles

- Pure functional core (optimizer, setpoint generator)
- Immutable data structures (state, trajectory, commands)
- Type-safe FFI via Ctypes (no unsafe casts)
- Algebraic data types for flight modes and waypoints

---

## Contribution Guidelines

- Zero comments dalam kode — semua self-documenting melalui penamaan dan tipe.
- Setiap file memiliki tanggung jawab tunggal yang jelas.
- Setiap fungsi SPARK harus memiliki kontrak formal yang lengkap.
- Setiap modul OCaml harus memiliki .mli dengan signature eksplisit.
- Commit messages mengikuti format: <type>(<scope>): <subject> (feat, fix, test, build, docs, etc.)

---

## Safety & Mission-Critical Assurance

- Triple-redundant voting (median selection)
- Health monitoring (suhu, arus, tekanan, posisi)
- Power distribution with overload detection & load shedding
- FSM dengan state: Idle, Active, Fault, Emergency
- Emergency override dengan rate limit 0.01 (safety-critical)

---

## Future Extensions

- Integration dengan real sensor hardware
- Logging & telemetry streaming
- Runtime assertion monitoring (RAM)
- Fuzzing harness with coverage oracle

---

## License

GPL-3.0 — untuk keperluan open-source aerospace research.

---

## Authors

Hybrid Arch Team — arsitektur monorepo polyglot OCaml + SPARK.
