# .devcontainer — Rust Agent Team

A GitHub Codespaces default devcontainer that installs a Copilot-powered
test generation and mutation analysis workflow into any personal Rust project.

## What this is

This repository does two things:

1. Defines a default Codespaces environment for all your personal Rust repos
   that do not have their own `.devcontainer` configuration.
2. Provides an agent team — a set of structured Copilot prompt files and
   just tasks — that helps you write, analyze, and improve unit tests using
   mutation testing.

## The agent team

Traditional code coverage tools tell you which lines were executed by your
tests. Mutation testing goes further — it makes small targeted changes to
your production code and checks whether your tests catch them. A test suite
that lets mutants survive is one that could miss real bugs.

The agent team is a structured workflow built on top of mutation testing.
Rather than asking you to interpret raw mutation output yourself, five
specialized Copilot agents guide you through the process from finding gaps
to improving tests to tracking lessons learned over time.

### Scout

Analyzes the codebase to find the highest-value targets for new or improved
tests. It reads coverage data, runs clippy, reviews existing tests, and ranks
functions by risk. It distinguishes between functions with zero test coverage
and those that are merely undertested, so you always know where to focus first.

### Writer

Takes the Scout report and writes the smallest useful set of strong unit
tests for the top target. It follows your codebase conventions, prefers
inline `#[cfg(test)]` modules, and covers happy path, boundary, malformed
input, and error cases. It does not add tests for the sake of coverage —
it targets meaningful assertions.

### Mutation Analyst

Reads the raw `cargo-mutants` output and classifies every surviving mutant
as a real test gap, a low-value survivor, or ignorable noise. For real gaps
it suggests the smallest test improvement that would likely kill the mutant.
It also flags redundant or weak tests worth pruning. The result is a
prioritized, actionable report rather than a raw list of survivors.

### Refiner

Takes the Mutation Analyst report and acts on it — strengthening weak
assertions, adding narrowly targeted missing tests, and pruning redundant
ones. It explains what it changed, which survivors it addressed, and which
it deliberately left alone and why.

### Coach

Reviews patterns across multiple Scout and Analyst sessions and recommends
improvements to the prompt files themselves. It only promotes a rule when
the same pattern has appeared multiple times, distinguishing between
observations that are pending, watching, or ready to promote. Over time
the Coach helps the whole agent team get smarter.

## How this improves test coverage

The workflow is designed to be iterative. A typical session looks like this:

1. Scout identifies the riskiest untested code
2. Writer adds a focused set of strong tests
3. Mutation testing reveals which tests are actually effective
4. The Analyst classifies the gaps and prioritizes fixes
5. The Refiner closes the most important gaps
6. Repeat steps 3–5 until the mutation score is satisfactory
7. The Coach captures lessons to improve future sessions

Each iteration raises your mutation score — the percentage of meaningful
code changes your tests would catch. A codebase starting at 20% can reach
70% or higher through a few focused sessions, with tests that are genuinely
effective rather than just lines-executed coverage padding.

---

## Environment

The devcontainer is based on Microsoft's official Rust image and includes:

- Rust stable with clippy and rustfmt
- `just` — task runner
- `cargo-mutants` — mutation testing
- `cargo-llvm-cov` — code coverage
- GitHub CLI
- VS Code extensions: rust-analyzer, CodeLLDB, Even Better TOML,
  GitHub Copilot, GitHub Copilot Chat

## Installing the agent team into a Rust project

Open this repo in Codespaces, clone your target repo alongside it, then run:

```bash
just install /workspaces/your-rust-project
```

This copies the following into your target repo:
- `.github/copilot-instructions.md`
- `.github/prompts/*.prompt.md`
- `.devcontainer/devcontainer.json`
- `justfile`
- Adds `agent-output/` and `mutants.out*` to `.gitignore`

Then commit and push in your target repo:

```bash
cd /workspaces/your-rust-project
git add .github/ .devcontainer/ justfile .gitignore agent-output/
git commit -m "add rust agent team"
git push
```

## Agent workflow

The agent team runs as a sequence of Copilot Chat prompts. Run them in order.
Each agent reads from and writes to files in `agent-output/` so context is
passed between steps without relying on chat session memory.

### Step 1 — Scout

In Copilot Chat:
```
#scout
```

Analyzes the codebase, identifies untested or risky functions, and ranks the
top testing targets. Writes output to `agent-output/scout.md`.

### Step 2 — Writer

In Copilot Chat:
```
#write-tests
```

Reads `agent-output/scout.md` and writes unit tests for the highest-value
target. Appends a dated summary to `agent-output/writer.md`.

### Step 3 — Mutate

In the terminal:
```bash
just mutate
```

Runs `cargo-mutants` across the codebase and writes results to
`agent-output/mutants.md`.

### Step 4 — Mutation Analyst

In Copilot Chat:
```
#analyze-mutations
```

Reads `agent-output/mutants.md`, classifies surviving mutants as real test
gaps, low-value survivors, or ignorable noise, and suggests targeted fixes.
Writes output to `agent-output/mutation-analysis.md`.

### Step 5 — Refiner

In Copilot Chat:
```
#refine-tests
```

Reads `agent-output/mutation-analysis.md` and strengthens weak tests or
prunes redundant ones. Writes a summary to `agent-output/refiner.md`.

### Step 6 — Coach

In Copilot Chat:
```
#coach
```

Reviews patterns across Scout and Analyst output and suggests improvements
to the prompt files themselves. Appends a dated entry to
`agent-output/coach-log.md`.

### Iterating

After the Refiner runs, repeat steps 3–5 until you are satisfied with the
mutation score. Run the Coach at the end of a full iteration cycle rather
than after every pass.

## Just tasks

| Task | Description |
|---|---|
| `just lint` | Run clippy |
| `just test` | Run unit tests |
| `just test-doc` | Run doc tests |
| `just mutate` | Run mutation testing, write results to `agent-output/mutants.md` |
| `just coverage` | Run llvm-cov, write results to `agent-output/coverage.md` |
| `just check` | Run lint, test, and test-doc |
| `just agent-scout` | Run lint as scout setup step |
| `just agent-write` | Run tests as writer validation step |
| `just agent-analyze` | Run mutation testing as analyst input step |
| `just agent-full` | Run full check then mutate |
| `just install <path>` | Install agent team into target repo |
| `just bootstrap` | Run bootstrap script |

## Agent output files

All agent output is written to `agent-output/` which is gitignored by default.

| File | Written by | Content |
|---|---|---|
| `agent-output/scout.md` | Scout | Current testing targets and risk ranking |
| `agent-output/writer.md` | Writer | Dated log of tests added per session |
| `agent-output/mutants.md` | `just mutate` | Raw cargo-mutants output |
| `agent-output/mutation-analysis.md` | Mutation Analyst | Survivor classification and fix suggestions |
| `agent-output/refiner.md` | Refiner | Summary of test improvements made |
| `agent-output/coach-log.md` | Coach | Dated log of prompt improvement recommendations |

## Notes

- The agent prompts rely on Copilot Chat prompt files, currently a GitHub
  Copilot preview feature. Prompt files must be enabled in VS Code settings.
- Feature-gated code (for example `--features wally`) will not be covered
  by default mutation runs. Add a separate `just mutate-wally` task if needed.
- The Coach is most useful after multiple sessions when it has accumulated
  enough pattern data in `agent-output/coach-log.md` to make reliable
  recommendations.
