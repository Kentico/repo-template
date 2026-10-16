# Status

## Current slice

2 – Rename script + smoke CI job: done locally (not committed). Next: 3 – `setup-repo` skill rewrite + naming reference.

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
| `setup-repo` skill | stale (still references removed `Repository-Setup.ps1`); rewrite in slice 3 |
| README / docs | template-info + tokens only; full rewrite in slice 3 |

## Open checks

- `System.Security.Cryptography.Pkcs` 10.0.0 NU1902/NU1903 warnings (transitive via Xperience 31.9.2). Check 31.9.3 or pin.
- `Kentico.Xperience.Templates` 31.9.3 available; first run of `update-xperience` (slice 4).
- Admin module Proxy mode not yet verified at runtime (needs DB).
- `setup-node` npm cache post-step in `template_smoke` after the Client path is renamed – confirm no failure on GitHub.
- Template repo slug assumed `Kentico/repo-template` for the smoke job guard.

## Pending decisions

- None.
