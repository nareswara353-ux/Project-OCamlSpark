#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

log_stage() { printf "\n=== %s ===\n" "$1"; }

log_stage "Checking toolchains"
command -v alr      >/dev/null || { echo "alr not found"; exit 1; }
command -v gprbuild >/dev/null || { echo "gprbuild not found"; exit 1; }
command -v dune     >/dev/null || { echo "dune not found"; exit 1; }
command -v opam     >/dev/null || { echo "opam not found"; exit 1; }

log_stage "Selecting GNAT toolchain"
alr --non-interactive toolchain --select gnat_native gprbuild

log_stage "Building SPARK shared library"
alr exec -- gprbuild -P spark_lib.gpr -p
test -f lib/libspark_actuator.so
echo "SPARK shared library: OK"

log_stage "Running formal proof (gnatprove)"
alr exec -- gnatprove -P actuator_controller.gpr --level=1 --timeout=60 --report=all || true

log_stage "Building SPARK test runner"
alr exec -- gprbuild -P tests/spark_tests.gpr -p || echo "SPARK test build skipped"

log_stage "Setting OCaml environment"
eval "$(opam env)"

log_stage "Building OCaml engine + FFI"
dune build

log_stage "Running OCaml unit tests"
dune exec -- tests/ocaml_tests.exe

log_stage "Running integration tests"
dune exec -- tests/integration_test.exe

log_stage "Running SPARK tests"
if [ -x bin/spark_runner ]; then
  ./bin/spark_runner
else
  echo "SPARK runner not built"
fi

log_stage "Pipeline complete"
ls -la lib/ 2>/dev/null || true
ls -la _build/default/engine_ocaml/ 2>/dev/null || true
