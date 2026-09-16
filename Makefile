SHELL := /bin/bash
OCAML_ENV := eval $(opam env)

.PHONY: all build test test-ocaml test-integration test-fuser run fmt clean help

all: build

build:
	$(OCAML_ENV) && dune build

test-ocaml:
	$(OCAML_ENV) && dune exec tests/ocaml_tests.exe

test-integration:
	$(OCAML_ENV) && dune exec tests/integration_test.exe

test-fuser:
	$(OCAML_ENV) && dune exec tests/fuser_test.exe

test: test-ocaml test-integration test-fuser

run:
	$(OCAML_ENV) && dune exec engine_ocaml/main.exe

fmt:
	$(OCAML_ENV) && dune fmt

clean:
	$(OCAML_ENV) && dune clean
	rm -rf obj lib bin

help:
	@echo "build, test, run, fmt, clean"
