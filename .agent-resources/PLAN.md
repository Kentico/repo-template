# Plan: committed-project repo template

## Goal

Template ships buildable, CI-verified projects under sentinel names. New repos are produced by rename + prune (script for mechanics, agent skills for judgment), not by scaffolding with `dotnet new`.

## Research

- Sibling repos (`xperience-by-kentico-component-registry`, `xperience-by-kentico-simple-stats`): Labs naming, net10, CPM + lock files, `.slnx` root + `src/*.Libs.slnx` for Azure DevOps, admin csproj npm targets (`NpmInstall`/`NpmBuildClient` on non-Debug), CI `setup-node` (node 24) + typecheck, DancingGoat overlay (SMTP, ManagementApi, Proxy mode, MCP).
- Community reference: <https://github.com/liamgold/xperience-community-map-location-selector> – built from an older template (`.sln`, net8, `src/Admin/` layout – don't copy structure). Take only: publish on GitHub release via NuGet Trusted Publishing (OIDC), `dependabot.yml`.
- Labs example reference: <https://github.com/Kentico/xperience-by-kentico-labs-e2e-testing> – example source code, repo slug includes `labs`, display name `Xperience by Kentico Labs: E2E Testing`, no consistent .NET naming.
- Template "Use this template" squashes history, so committed DancingGoat (incl. `Data/Template.zip`) adds no history weight to new repos.

## Design rules

- Core library, no name suffix: `src/Kentico.Xperience.RepoTemplate` (references `Kentico.Xperience.WebApp`).
- Any project with admin UI extensions ends in `.Admin`: `src/Kentico.Xperience.RepoTemplate.Admin` (references core). Its client module key ends in `-admin`.
- Target `net10.0`.
- Projects override shared props (e.g. `RootNamespace`) rather than inherit repo-wide values.
- Tests and examples are `IsPackable=false`.
- Lock files committed; restore with `--locked-mode`.
- Skills live only in `.claude/skills/`.
- Agent plans/specs go in `.agent-resources/`.
- Naming, tokens, and per-family edits: single source of truth is `.claude/skills/setup-repo/references/` (`naming.md`, `family-edits.md`, `remove-admin.md`).

## Slices

1. Baseline: props fixes, net10, gitignore, commit core/.Admin/tests/DancingGoat under tokens, admin npm wiring, CI Node.
2. Rename script + template-only smoke CI job.
3. `setup-repo` skill rewrite + references; Community `publish.yml` (pulled forward from 5).
4. `update-xperience` skill + `references/dancinggoat-overlay.md` (regenerate DancingGoat, re-apply overlay, bump NuGet + `@kentico/*` npm).
5. dependabot; remaining AGENTS.md updates.

## Decisions

- 2026-10-15: commit projects instead of scaffolding. Change placeholders to sentinel tokens (drop `REPOSITORY_NAME`). net10. Labs not in library repo names. Community publishes from GitHub workflows. Skills only in `.claude/skills`.
- 2026-10-15: admin module key format `<prefix>-<name>-admin` confirmed.
- 2026-10-16: core (no suffix) + `.Admin` project; admin UI projects always end in `.Admin`, client module in `-admin`. DancingGoat references core and `.Admin` unconditionally; its `SeparatedAdmin` option is ignored (almost no Xperience apps separate the admin).
- 2026-10-16: families are Kentico, Labs, Community (support policy). Example is a separate choice under any family: not packed or published; Labs examples put `labs` in the repo slug. Product names: `Xperience by Kentico: X`, `Xperience by Kentico Labs: X`, `Xperience Community: X`.

## Slice log

- 2026-10-15/16 – Slice 1: committed core/.Admin/tests/DancingGoat (templates 31.9.2), net10, CPM + lock files, admin npm targets, CI Node + typecheck, pipeline/tasks. Release build, tests, format verified locally.
- 2026-10-16 – Slice 2: `Rename-Template.ps1` (in `setup-repo` skill) + `template_smoke` CI matrix; `Repository-Setup.ps1` removed. Community + Labs renames verified locally.
- 2026-10-16 – Slice 3: `setup-repo` skill (11 steps) + `naming.md`, `family-edits.md`, `remove-admin.md`; script gains `-Preview`, `-Example`, `-DisplayName`, removes `template_smoke`, sets LICENSE year; `publish.yml`. Fresh-agent runs: Community/no-admin and Labs/admin green after fixes (smoke-job guard tripped the leftover check; product-name prefix; untracked grep).
- 2026-10-16 – Slice 4: `update-xperience` skill + `Update-Xperience.ps1` (three-way merge of pristine current/target DancingGoat with the repository copy; NuGet, tool, npm bumps) + `dancinggoat-overlay.md`. Template updated 31.9.2 → 31.9.3 with it; conflict path verified on a scratch copy.
