# Plan: committed-project repo template

## Goal

Template ships buildable, CI-verified projects under sentinel names. New repos are produced by rename + prune (script for mechanics, agent skills for judgment), not by scaffolding with `dotnet new`.

## Research

- Sibling repos (`xperience-by-kentico-component-registry`, `xperience-by-kentico-simple-stats`): Labs naming, net10, CPM + lock files, `.slnx` root + `src/*.Libs.slnx` for Azure DevOps, admin csproj npm targets (`NpmInstall`/`NpmBuildClient` on non-Debug), CI `setup-node` (node 24) + typecheck, DancingGoat overlay (SMTP, ManagementApi, Proxy mode, MCP).
- Community reference: <https://github.com/liamgold/xperience-community-map-location-selector> – built from an older template (`.sln`, net8, `src/Admin/` layout – don't copy structure). Take only: publish on GitHub release via NuGet Trusted Publishing (OIDC), `dependabot.yml`.
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

## Sentinel tokens

| Token | Replaced with |
| --- | --- |
| `Kentico.Xperience.RepoTemplate` | .NET project / assembly / namespace / package ID |
| `xperience-by-kentico-repotemplate` | repository slug |
| `kentico-xperience-repotemplate-admin` | admin client module key (npm package name, Proxy settings key) |
| `kentico` + `xperience-repotemplate-admin` | admin org + project name (`AdminOrgName`, `ProjectName`, `RegisterClientModule`, webpack, `UIApplication` template path); module key = `<org>-<project>` |
| `RepoTemplate` | short name (DB name, `App_Data` folder, tags) |
| `github.com/Kentico/` | GitHub org (community: author org) |

## Families

| Family | .NET name | Repo | Admin module | Publish | Support |
| --- | --- | --- | --- | --- | --- |
| Fully supported | `Kentico.Xperience.X` | `xperience-by-kentico-x` | `kentico-xperience-x-admin` | Azure DevOps (signed) | 7-day bug-fix badge |
| Labs | `Kentico.Xperience.Labs.X` | `xperience-by-kentico-x` | `kentico-xperience-labs-x-admin` | Azure DevOps (signed) | Labs badge |
| Community | `XperienceCommunity.X` | author choice (e.g. `xperience-community-x`) | `xperience-community-x-admin` | GitHub release workflow, Trusted Publishing | none; author support |
| Example | `Kentico.Xperience.Examples.X` (proposed) | `xperience-by-kentico-x` (proposed) | `kentico-xperience-examples-x-admin` (proposed) | none, `IsPackable=false` | none |

Community also changes `Company`/`Authors`, CODEOWNERS, license holder, drops `.azuredevops/` and code signing.

## Slices

1. Baseline: props fixes, net10, gitignore, commit main/tests/DancingGoat projects under tokens, admin npm wiring, CI Node, tasks/pipeline aligned to single project.
2. Rename script + template-only smoke CI job (rename with sample name, build, test, assert no tokens left).
3. `setup-repo` skill rewrite + `references/naming.md` (families table, token map, prune rules).
4. `update-xperience` skill + `references/dancinggoat-overlay.md` (regenerate DancingGoat, re-apply overlay, bump NuGet + `@kentico/*` npm).
5. Family publish paths: community GitHub publish workflow + dependabot; AGENTS.md updates.

## Decisions

- 2026-10-15: commit projects instead of scaffolding. Change placeholders to sentinel tokens (drop `REPOSITORY_NAME`). net10. No "Core" project. Labs not in repo name. Community publishes from GitHub workflows. Skills only in `.claude/skills`.

- 2026-10-15: example family naming confirmed. Admin module key format `<prefix>-<name>-admin` confirmed.
- 2026-10-16: core (no suffix) + `.Admin` project; admin UI projects always end in `.Admin`, client module in `-admin`. DancingGoat references core and `.Admin` unconditionally; its `SeparatedAdmin` option is ignored (almost no Xperience apps separate the admin).

## Slice log

- 2026-10-15/16 – Slice 1: committed core/.Admin/tests/DancingGoat (templates 31.9.2), net10, CPM + lock files, admin npm targets, CI Node + typecheck, pipeline/tasks single project. Release build, tests, format verified locally.
- 2026-10-16 – Slice 2: `Rename-Template.ps1` (in `setup-repo` skill) + `template_smoke` CI matrix; `Repository-Setup.ps1` removed. Community + Labs renames verified locally.
