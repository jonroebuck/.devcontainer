set shell := ["bash", "-cu"]

default:
    @just --list

bootstrap:
    bash scripts/bootstrap-agent-team.sh

lint:
    cargo clippy -- -D warnings

test:
    cargo test

test-doc:
    cargo test --doc

mutate:
    mkdir -p agent-output
    cargo mutants 2>&1 | tee agent-output/mutants.md

check:
    just lint
    just test
    just test-doc

agent-scout:
    just lint || true

agent-write:
    just test

agent-analyze:
    just mutate

agent-full:
    just check || true
    just mutate