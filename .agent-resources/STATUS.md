# Status

## Current slice

3 – `setup-repo` skill rewrite: done (agent-tested Community/no-admin, Labs/admin, Labs example/no-admin). Slices 1–2 committed (`0ee32cc`). Next: 4 – `update-xperience` skill.

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
| README / docs | tokenized; rewritten per repo by `setup-repo` step 8 |

## Open checks

- `System.Security.Cryptography.Pkcs` 10.0.0 NU1902/NU1903 warnings (transitive via Xperience 31.9.2). Check 31.9.3 or pin.
- `Kentico.Xperience.Templates` 31.9.3 available; first run of `update-xperience` (slice 4).
- Admin module Proxy mode not yet verified at runtime (needs DB).
- `setup-node` npm cache post-step in `template_smoke` after the Client path is renamed – confirm no failure on GitHub.
- `publish.yml` untested (needs nuget.org Trusted Publishing).
- DancingGoat `Program.cs` using for the renamed core namespace may sort out of order (`examples/` not formatted).
- Template repo slug assumed `Kentico/repo-template` for the smoke job guard.

## Pending decisions

- None.
