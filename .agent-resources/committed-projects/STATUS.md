# Status

## Current slice

All planned slices (1–5) done. Branch `feat/committed-projects`; nothing has run on GitHub CI yet.

## Components

| Component | State |
| --- | --- |
| `src/Kentico.Xperience.RepoTemplate` (core) | done |
| `src/Kentico.Xperience.RepoTemplate.Admin` | done |
| `tests/Kentico.Xperience.RepoTemplate.Tests` | done |
| `examples/DancingGoat` + overlay | done |
| CI Node + typecheck | done, not yet run on GitHub |
| `Rename-Template.ps1` | done; verified locally for Community + Labs (locked restore, Release build, tests) |
| CI `template_smoke` matrix | done, not yet run on GitHub |
| `setup-repo` skill + references | done; agent-tested 3 paths |
| `publish.yml` (Community) | written, not yet run |
| `update-xperience` skill + script | done; real run 31.9.2 → 31.9.3, conflict path tested |
| `dependabot.yml` | done, not yet run on GitHub |
| `design-conventions` skill (root) | done; recovered full content from 31.9.3 template (DancingGoat copy was a stub importing the removed `.github/skills`) |
| README / docs | tokenized; rewritten per repo by `setup-repo` step 8 |

## Open checks

- `System.Security.Cryptography.Pkcs` pinned to 10.0.13 (transitive pin); remove when Xperience ships a patched dependency.
- Dependabot NuGet updates with committed `packages.lock.json` + `--locked-mode` CI – confirm lock files get updated in its PRs.
- Admin module Proxy mode not yet verified at runtime (needs DB).
- `setup-node` npm cache post-step in `template_smoke` after the Client path is renamed – confirm no failure on GitHub.
- `publish.yml` untested (needs nuget.org Trusted Publishing).
- DancingGoat `Program.cs` using for the renamed core namespace may sort out of order (`examples/` not formatted).
- Template repo slug assumed `Kentico/repo-template` for the smoke job guard.

## Pending decisions

- None.
