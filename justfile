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

coverage:
    mkdir -p agent-output
    cargo llvm-cov 2>&1 | tee agent-output/coverage.md

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

audit:
    @echo "Run #audit in Copilot Chat"

gate:
    just coverage
    @echo "Run #gate in Copilot Chat"

classify:
    @echo "Run #classify in Copilot Chat"

refactor:
    @echo "Run #refactor in Copilot Chat"

verify:
    just test
    @echo "Run #verify in Copilot Chat"

coach-solid:
    @echo "Run #coach-solid in Copilot Chat"

solid-full:
    just audit
    just gate
    just classify
    just refactor
    just verify

pr:
    gh workflow run solid-refactor.yml -f dry_run=false

pr-dry:
    gh workflow run solid-refactor.yml -f dry_run=true

install target:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -d "{{target}}" ]; then
        echo "Error: {{target}} is not a directory"
        exit 1
    fi
    if [ -f "{{target}}/.github/copilot-instructions.md" ]; then
        echo "Warning: copilot-instructions.md already exists in {{target}}/.github/"
        read -r -p "Overwrite? [y/N] " confirm
        [[ "$confirm" =~ ^[Yy]$ ]] || exit 0
    fi
    if [ -f "{{target}}/justfile" ]; then
        echo "Warning: justfile already exists in {{target}}"
        read -r -p "Overwrite? [y/N] " confirm
        [[ "$confirm" =~ ^[Yy]$ ]] || exit 0
    fi
    mkdir -p {{target}}/.github/prompts
    mkdir -p {{target}}/.github/workflows
    mkdir -p {{target}}/agent-output
    cp .github/copilot-instructions.md {{target}}/.github/copilot-instructions.md
    cp .github/prompts/*.prompt.md {{target}}/.github/prompts/
    cp .github/workflows/solid-refactor.yml {{target}}/.github/workflows/solid-refactor.yml
    cp justfile {{target}}/justfile
    mkdir -p {{target}}/.github/workflows
    cp .github/workflows/agent-team.yml {{target}}/.github/workflows/agent-team.yml
    mkdir -p {{target}}/.devcontainer
    cp .devcontainer/devcontainer.json {{target}}/.devcontainer/devcontainer.json
    if ! grep -q '^agent-output/$' {{target}}/.gitignore 2>/dev/null; then
        echo "" >> {{target}}/.gitignore
        echo "# Local agent-team output" >> {{target}}/.gitignore
        echo "agent-output/" >> {{target}}/.gitignore
    fi
    if ! grep -q '^mutants\.out\*$' {{target}}/.gitignore 2>/dev/null; then
        echo "mutants.out*" >> {{target}}/.gitignore
    fi
    echo "Agent team installed into {{target}}"