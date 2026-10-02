SHELL := /bin/bash
OCAML_ENV := eval $(opam env)

TESTS := ocaml_tests integration_test fuser_test logger_test error_test \
         time_util_test result_util_test ring_buffer_test event_bus_test \
         telemetry_test metrics_test config_test config_loader_test \
         validator_test sanitizer_test waypoint_parser_test serializer_test

.PHONY: all build test test-all run fmt clean help $(TESTS)

all: build

build:
	$(OCAML_ENV) && dune build

test-all:
	$(OCAML_ENV) && for t in $(TESTS); do \
	  echo "=== Running $$t ==="; \
	  dune exec tests/$$t.exe || exit 1; \
	done

$(TESTS):
	$(OCAML_ENV) && dune exec tests/$@.exe

test: test-all

run:
	$(OCAML_ENV) && dune exec engine_ocaml/main.exe

fmt:
	$(OCAML_ENV) && dune fmt

clean:
	$(OCAML_ENV) && dune clean
	rm -rf obj lib bin

help:
	@echo "Targets: build, test-all, test, run, fmt, clean"
	@echo "Individual tests: $(TESTS)"
