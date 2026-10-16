# Slice 3 – CI e2e job

## Scope

- `.github/workflows/ci.yml` `e2e` job (before the template-only marker, so setup keeps it):
  - services: `mssql/server:2022-latest` (health check via `sqlcmd`), `axllent/mailpit`
  - `HAS_LICENSE` from `secrets.XPERIENCE_LICENSE_KEY` (job-level `env`; `secrets` can't be used in job `if`); every step after checkout skips without it, with a notice
  - license key → temp file → `Initialize-Database.ps1 -LicenseFile` (CI keeps values in `appsettings.json`); Release build (admin client embedded); `npm ci`, Playwright Chromium with deps, typecheck, `npm test`; HTML report artifact
  - DancingGoat via Playwright `webServer`: `dotnet run --configuration Release --no-build --no-launch-profile`, `ASPNETCORE_ENVIRONMENT=CI`, `ASPNETCORE_URLS=http://localhost:5080`
- `examples/DancingGoat/appsettings.CI.json`: SMTP to Mailpit, `SystemEmailOptions`; no Proxy entry. Listed in `dancinggoat-overlay.md`.
- `setup-repo`: report step asks for the `XPERIENCE_LICENSE_KEY` repository + Dependabot secret; `remove-admin.md` covers the e2e job's admin cache path.

## Findings

- Xperience's command-line parser rejects `--urls` ("Option 'urls' is unknown"); use `ASPNETCORE_URLS`.
- The Management API is Development-only, so it is off in CI without extra config.

## Verification

- Local CI simulation (Release build, `ASPNETCORE_ENVIRONMENT=CI`, `CI=1`, CI server command, connection string + salt via environment variables): 6/6 pass with the embedded admin client.
- Community rename on a scratch copy keeps the `e2e` job and renames its paths.
- Not yet run on GitHub (needs the secret and a PR to `main`).
