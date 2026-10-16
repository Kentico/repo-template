# Agent instructions

## Development

- Before a commit, format with: `dotnet format --no-restore`
- `examples/` is excluded from formatting by `examples/.editorconfig` (`generated_code = true`)
- The Dancing Goat connection string and management API secret can be committed to source control because they are for local development only.
- Package versions live only in `Directory.Packages.props`; lock files are committed, so restore with `--force-evaluate` after changing versions or project references.

## Xperience version and DancingGoat

- `Kentico.Xperience.*` NuGet and `@kentico/*` npm versions change only through the `update-xperience` skill, which also regenerates `examples/DancingGoat` from the matching project template.
- `examples/DancingGoat` is template-generated. When you change it beyond demonstrating this repository's library (project references, settings, startup), record the change in `.claude/skills/update-xperience/references/dancinggoat-overlay.md` so updates keep it.
- `examples/DancingGoat/AGENTS.md` has instructions for the sample app.

## Planning docs (`.agent-resources/<feature>/`)

Each feature gets its own folder, `.agent-resources/<feature>/` (kebab-case name). Write all agent plans, research, and implementation specs for that feature there, not elsewhere in the repo. Before working on an existing feature, read its `STATUS.md`.

- `STATUS.md` – single source for the feature's current state (components, open checks, pending decisions). Update after each slice or when an item closes.
- `PLAN.md` – the feature's research, design rules, component catalog, decisions, append-only slice log. Don't track status there.
- `implementation-spec-<n>.md` – scope of slice `<n>` of the feature.
