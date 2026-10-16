# Status

## Current slice

Slice 2 (Playwright e2e project) in progress: project written, blocked on a license for local verification. Branch `feat/local-environment`, stacked on #24.

## Components

| Component | State |
| --- | --- |
| Database init script | done (`scripts/Initialize-Database.ps1`) |
| Playwright e2e project | written (`tests/e2e`); admin sign-in setup passes; other tests need a license |
| CI e2e job | not started |
| Aspire AppHost | not started |
| CI restore support | not started (optional) |

## Open checks

- Without a license the live site returns 500 (`LicenseCheckerMiddleware`) and the admin shows only the license prompt + Configuration, hiding custom applications. Local e2e and the CI e2e job need a license; CI via a repository secret (not available to fork PRs).
- Local `examples/DancingGoat/appsettings.json` carries the `dbmanager` salt for the local test database – never commit it.
- Playwright admin sign-in with the `dbmanager`-created admin account in CI.
- Aspire package versions and agent tooling (`aspire` CLI / MCP) current state.

## Pending decisions

- None.
