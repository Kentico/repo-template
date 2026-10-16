# Plan: local environment (e2e tests + Aspire)

## Goal

One-command local startup for DancingGoat and the template's libraries, and Playwright e2e tests that validate live-site and admin UI behavior locally and in CI.

## Research

- `Kentico/xperience-by-kentico-labs-e2e-testing`: TypeScript Playwright in `tests/` (`playwright.config.ts`, projects `admin-tests` + `live-site`, `auth.setup.ts` storage state, page objects, `membership/emailClient.ts`, `scenarios/*.e2e.md` for agent-authored tests). Its admin tests cover the admin sample's custom template page – the same page this template ships.
- `Kentico/xperience-by-kentico-simple-stats` CI: `mssql/server:2022` service container + `dotnet kentico-xperience-dbmanager` to create the database.
- Kentico docs: Aspire AppHost with an Xperience project is documented (logging/OTLP dashboard example).
- 31.9.3 DancingGoat `AGENTS.md` already assumes Aspire ("the port is dynamic under Aspire").
- `kentico-xperience-dbmanager` creates databases without a license file; the license is then added on first admin sign-in. When a license file exists on the machine, pass it to `dbmanager` to skip that step.

## Design rules

- e2e tests do not depend on Aspire: base URL from an environment variable, default from DancingGoat `launchSettings.json`.
- DancingGoat stays free of Aspire code (no ServiceDefaults); the AppHost injects connection string and ports through environment variables, so plain `dotnet run` with `appsettings.json` keeps working and the `update-xperience` overlay stays small.
- SQL Server: Docker container by default (persistent volume); a locally installed SQL Server is supported by configuration instead.
- Email: Mailpit (SMTP 1025, matching DancingGoat `SystemSmtpOptions`), used by membership/email e2e tests.
- Database: created by `dbmanager` (optional license file path). `dbmanager` owns `CMSHashStringSalt`: the template ships it empty and `dbmanager` sets it on database creation. Optional CI restore step for repositories that ship CI repository files; extensions that create their objects on startup (Lucene, Tag Manager pattern) need none.
- CI e2e runs a Release build (admin client embedded) with `ASPNETCORE_ENVIRONMENT=CI`: `examples/DancingGoat/appsettings.CI.json` holds SMTP (Mailpit) and other test settings and has no `CMSAdminClientModuleSettings` Proxy entry; recorded in `dancinggoat-overlay.md`. Local runs may use Debug + Proxy.
- Admin e2e tests stay even without an `.Admin` project: libraries adding widgets, automation steps, etc. still change admin UI behavior.

## Slices

1. Database init: script wrapping `dbmanager` (server, database name from `appsettings.json`, admin password, optional license file), usable locally and in CI.
2. Playwright e2e project (`tests/e2e`): config, admin auth setup, one admin smoke test (custom template page), one live-site test; npm scripts; `setup-repo`/rename coverage.
3. CI e2e job: mssql + Mailpit service containers, database init, start DancingGoat, run Playwright, upload report.
4. Aspire AppHost (`examples/AppHost`): SQL (container or local), Mailpit, DancingGoat, admin client `npm start` (Proxy mode), database init on first run; docs and `setup-repo`/`update-xperience` updates.
5. Optional CI restore support (Continuous Integration repository files) for custom Xperience apps.

## Decisions

- 2026-10-16: add both e2e (first) and Aspire; Docker acceptable for Aspire, local SQL Server should also work; no license needed for database creation.
- 2026-10-16: `dbmanager` owns `CMSHashStringSalt`; setup no longer generates it (changed on `committed-projects`).
- 2026-10-16: e2e needs a licensed instance. Local: `-LicenseFile` / `XPERIENCE_LICENSE_FILE`. CI: `XPERIENCE_LICENSE_KEY` repository secret (also as a Dependabot secret); e2e skips when unavailable. Community repos bring their own license.
- 2026-10-16: `Initialize-Database.ps1` moves dbmanager's connection string + salt into DancingGoat user secrets (not in CI); a `setup-local` skill guides new clones.

## Slice log

- 2026-10-16 – Slice 1: `scripts/Initialize-Database.ps1` (dbmanager wrapper, defaults from DancingGoat connection string, optional license, `-Recreate`); contributing docs updated. Verified against Docker SQL Server 2022.
- 2026-10-16 – Slice 2: `tests/e2e` Playwright project (live-site + admin), user-secrets handoff in the database script, dependabot/docs/setup wiring. 6/6 pass locally with a license.
- 2026-10-16 – Slice 3: CI `e2e` job (mssql + Mailpit services, license secret gate, Release build, Playwright) + `appsettings.CI.json`. Local CI simulation 6/6.
