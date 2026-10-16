# Agent instructions

## Development

- Before a commit, format with: `dotnet format --no-restore`
- `examples/` is excluded from formatting by `examples/.editorconfig` (`generated_code = true`)
- The Dancing Goat connection string and management API secret can be committed to source control because they are for local development only.

- `examples/DancingGoat/AGENTS.md` has instructions for the sample app

## Planning docs (`.agent-resources/`)

Write all agent plans, research, and implementation specs to `.agent-resources/`, not elsewhere in the repo.

- `STATUS.md` – single source for current state (components, open checks, pending decisions). Update after each slice or when an item closes.
- `PLAN.md` – research, design rules, component catalog, decisions, append-only slice log. Don't track status there.
- `implementation-spec-*.md` – scope of each slice.
