# Slice 2 – Playwright e2e project

## Scope

- `tests/e2e` (TypeScript, Playwright 1.61, adapted from `xperience-by-kentico-labs-e2e-testing`):
  - projects `live-site`, `admin-setup` (sign in once, save storage state), `admin-tests`
  - `shared/config.ts`: base URL from `DANCING_GOAT_BASE_URL` or the DancingGoat launch profile (follows the port randomized by setup); admin credentials match `Initialize-Database.ps1`
  - `webServer` starts DancingGoat unless running; readiness URL is `/admin` (the live site returns 500 without a license)
  - specs: admin sign-in smoke, custom template page (category navigation + page command), live-site home + articles navigation
  - template tokens in the page object (`repotemplate`, `Repo Template`) so setup renames them
- `Initialize-Database.ps1`: moves `dbmanager`'s connection string and salt into DancingGoat user secrets and restores `appsettings.json` (skipped in CI or with `-NoUserSecrets`).
- dependabot npm entry for `tests/e2e`; contributing docs pointer; `remove-admin.md` drops only the custom template spec/page and the Proxy note.

## Findings

- No license: live site 500 (`LicenseCheckerMiddleware`); admin sign-in works but shows only the license prompt and Configuration, hiding custom applications.
- Repository secrets reach same-repo PRs, not fork PRs; Dependabot-triggered runs read the separate Dependabot secret store.

## Verification

- Licensed local database (Docker SQL Server 2022), Development + admin client `npm start`: 6/6 tests pass; `tsc --noEmit` passes.
- Labs rename on a scratch copy: exit 0, e2e page object renamed (`content-audit`, `Content Audit`).
