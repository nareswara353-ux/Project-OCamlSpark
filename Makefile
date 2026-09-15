SHELL := /bin/bash
SPARK_GPR := spark_lib.gpr
CONTROLLER_GPR := actuator_controller.gpr
SPARK_LIB := lib/libspark_actuator.so
OCAML_ENV := eval $(opam env)

.PHONY: all spark proof ocaml test test-spark test-ocaml test-integration clean distclean fmt

all: spark ocaml

spark: $(SPARK_LIB)

$(SPARK_LIB): $(shell find core_spark -name '*.ads' -o -name '*.adb') $(SPARK_GPR)
	alr exec -- gprbuild -P $(SPARK_GPR) -p
	@echo "SPARK shared library built: $(SPARK_LIB)"

proof:
	alr exec -- gnatprove -P $(CONTROLLER_GPR) --level=1 --timeout=60 --report=all

ocaml:
	$(OCAML_ENV) && dune build
	@echo "OCaml engine and FFI built"

test-spark:
	alr exec -- ./obj/spark_tests

test-ocaml:
	$(OCAML_ENV) && dune exec -- tests/ocaml_tests.exe

test-integration:
	$(OCAML_ENV) && dune exec -- tests/integration_test.exe

test: test-ocaml test-integration

run:
	$(OCAML_ENV) && dune exec -- engine_ocaml/actuator_main.exe

fmt:
	$(OCAML_ENV) && dune fmt

clean:
	rm -rf obj lib _build
	rm -f *.ali

distclean: clean
	rm -rf _alire alire.lock
	$(OCAML_ENV) && dune clean

help:
	@echo "Available targets:"
	@echo "  all             Build SPARK library and OCaml engine"
	@echo "  spark           Build SPARK shared library only"
	@echo "  proof           Run formal verification via gnatprove"
	@echo "  ocaml           Build OCaml engine and FFI"
	@echo "  test-spark      Run SPARK unit tests (AUnit)"
	@echo "  test-ocaml      Run OCaml unit tests (Alcotest)"
	@echo "  test-integration Run end-to-end integration tests"
	@echo "  test            Run OCaml and integration tests"
	@echo "  run             Execute actuator_main"
	@echo "  clean           Remove build artifacts"
	@echo "  distclean       Full cleanup including Alire cache"
