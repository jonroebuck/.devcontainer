# Copilot instructions for this Rust repository
You are helping on a Rust project in GitHub Codespaces.
## Core behavior
- Prefer unit tests close to the code under test in `#[cfg(test)] mod tests`.
- Use integration tests in `tests/` only when public API behavior is the main concern.
- Do not modify production code unless explicitly asked.
- Do not add or modify dependencies in `Cargo.toml` unless explicitly asked.
- Before proposing tests, inspect nearby existing tests and mirror their style.
- If no existing tests are present, default to descriptive snake_case test names and one assertion per test.
- Prefer focused assertions over broad smoke tests.
- Avoid duplicate happy-path tests unless they add materially different assertions.
## Test strategy
When writing or improving tests, consider:
- happy path
- boundary values
- malformed input
- minimal input
- error propagation
- parser edge cases such as trailing separators, empty input, and off-by-one boundaries
When mutation results are available:
- classify surviving mutants into:
  - real test gap
  - low-value survivor
  - ignorable noise
- strengthen weak assertions before adding lots of new tests
- prune redundant tests if they add no mutation-killing value
## Commands to use
Use these commands when relevant:
- `just lint`
- `just test`
- `just test-doc`
- `just mutate`
- `just check`
Note: these tasks must be defined in the target repository's justfile.
## Output style
- Be concise and specific.
- Summarize what changed in short bullets.
- If you are unsure, say what is ambiguous rather than inventing behavior.