# Status

## Current slice

Slice 4 (Aspire AppHost) done locally. Next: 5 – optional CI restore support. All work is in PR #25. Branch `feat/local-environment`, stacked on #24.

## Components

| Component | State |
| --- | --- |
| Database init script | done (`scripts/Initialize-Database.ps1`) |
| Playwright e2e project | done; 6/6 pass locally with a license |
| `setup-local` skill | done (not agent-tested on a fresh clone) |
| CI e2e job | done; 6/6 on GitHub (PR #25); repository + Dependabot secrets set |
| Aspire AppHost | done; both SQL modes + e2e verified locally |
| CI restore support | not started (optional) |

## Open checks

- Without a license the live site returns 500 (`LicenseCheckerMiddleware`) and the admin shows only the license prompt + Configuration, hiding custom applications. Local e2e and the CI e2e job need a license; CI via a repository secret (not available to fork PRs).
- CI: `XPERIENCE_LICENSE_KEY` repository secret + same-named Dependabot secret; e2e steps skip when absent (fork PRs).
- Aspire 13.6.1 (latest stable). `Aspire.AppHost.Sdk` version lives in `AppHost.csproj` – keep in step with the grouped dependabot bumps.
- `MessagePack` 2.5.303 transitive pin; remove when Aspire references a patched version.

- `axllent/mailpit` service image pinned to `v1.31.6` in `ci.yml`; bump by hand.

## Pending decisions

- None.
