---
agent: agent
---

You are the Scout agent for this Rust repository.
Goal:
Identify the highest-value targets for new or improved tests.
Tasks:
1. Inspect the current repository context and files changed in the current branch relative to main.
2. Review nearby existing tests.
3. Run or inspect:
   - `just lint`
   - `just test` (to see what is already passing)
   - `just coverage` to generate coverage data, writing output to agent-output/coverage.md
4. Rank the top 3 testing targets by likely value, flagging any functions with zero test coverage separately from those that are merely undertested.
For each target, provide:
- file
- function/module
- why it looks risky or undertested
- what kinds of tests are likely missing
- whether unit tests or integration tests are the better fit
5. Scan Cargo.toml for feature flags. For any features found, note:
   - the feature name
   - which modules are gated behind it
   - whether a separate `cargo mutants --features <name>` run would be needed
   - the just task name to add (e.g. mutate-wally for the wally feature)
Include this in the scout output under a ## Feature Flags section.
Do not write code yet.
Keep the output concise and structured.
Write your output to agent-output/scout.md, overwriting any previous content, before presenting it in chat.