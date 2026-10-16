# Slice 3 – `setup-repo` skill rewrite

## Scope

- `.claude/skills/setup-repo/SKILL.md`: 11 ordered steps, each with a completion criterion: check state → agree names (`-Preview`) → rename → remove `.Admin` (optional) → family edits → product text → remove template-only material → rewrite docs → validate → delete skill → report.
- `references/naming.md`: families table (.NET, repo, admin module key, display name), projects, admin client module agreement points, token map.
- `references/family-edits.md`: publishing (Azure DevOps vs `publish.yml` vs none), ownership (Company/Authors, LICENSE, CODEOWNERS, logo), README support badges/text.
- `references/remove-admin.md`: every file touched when the `.Admin` project is dropped.
- `Rename-Template.ps1`: `-Preview` (prints names, no changes), `-Example` (example repo under any family; Labs slug gets `labs`), `-DisplayName` (product name + display strings via `Repo Template` tokens); removes the `template_smoke` job itself; sets `LICENSE.md` year.
- Families reduced to Kentico, Labs, Community; Example is orthogonal.
- `.github/workflows/publish.yml` (pulled forward from slice 5): Community publishing on GitHub release via NuGet Trusted Publishing (`NUGET_USER` repo variable).
- README template-info naming section points to `references/naming.md`.

## Verification

Fresh-context subagent runs on scratch copies: Community without `.Admin`, Labs with `.Admin`, then Labs example without `.Admin` after fixes. Friction they report feeds back into the skill.

## Out of scope

- `update-xperience` skill (slice 4), dependabot (slice 5).
