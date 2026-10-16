# Status

## Current slice

Slice 3 (CI e2e job) done locally; not yet run on GitHub. Next: 4 – Aspire AppHost. Branch `feat/local-environment`, stacked on #24.

## Components

| Component | State |
| --- | --- |
| Database init script | done (`scripts/Initialize-Database.ps1`) |
| Playwright e2e project | done; 6/6 pass locally with a license |
| `setup-local` skill | done (not agent-tested on a fresh clone) |
| CI e2e job | done; local CI simulation 6/6; GitHub run pending (`XPERIENCE_LICENSE_KEY` secret) |
| Aspire AppHost | not started |
| CI restore support | not started (optional) |

## Open checks

- Without a license the live site returns 500 (`LicenseCheckerMiddleware`) and the admin shows only the license prompt + Configuration, hiding custom applications. Local e2e and the CI e2e job need a license; CI via a repository secret (not available to fork PRs).
- CI: `XPERIENCE_LICENSE_KEY` repository secret + same-named Dependabot secret; e2e steps skip when absent (fork PRs).
- Aspire package versions and agent tooling (`aspire` CLI / MCP) current state.

## Pending decisions

- None.
