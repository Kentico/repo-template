# Status

## Current slice

4 – `update-xperience` skill: done locally; template bumped to 31.9.3. Slices 1–3 pushed (`0ee32cc`, `6eb5fd3`). Next: 5 – dependabot, remaining AGENTS.md updates.

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
| README / docs | tokenized; rewritten per repo by `setup-repo` step 8 |

## Open checks

- `System.Security.Cryptography.Pkcs` 10.0.0 NU1902/NU1903 warnings remain on 31.9.3 (transitive via Xperience). Pin a patched version centrally, or wait for Kentico.
- Admin module Proxy mode not yet verified at runtime (needs DB).
- `setup-node` npm cache post-step in `template_smoke` after the Client path is renamed – confirm no failure on GitHub.
- `publish.yml` untested (needs nuget.org Trusted Publishing).
- DancingGoat `Program.cs` using for the renamed core namespace may sort out of order (`examples/` not formatted).
- Template repo slug assumed `Kentico/repo-template` for the smoke job guard.

## Pending decisions

- None.
