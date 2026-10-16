---
name: setup-local
description: Set up a local development environment for this repository - SQL Server, the DancingGoat database with an Xperience license, user secrets, npm packages, and Playwright browsers. Use after cloning the repository, or when a developer needs a new local database.
---

Each step ends on its completion criterion. Run from the repository root.

## 1. Check prerequisites

- .NET SDK matching `global.json` (`dotnet --version`)
- Node.js matching `engines` in `tests/e2e/package.json` (`node --version`)
- SQL Server: ask the user whether to use Docker or a locally installed SQL Server.
  - Docker: if nothing listens on port 1433, start one matching the default connection string in `examples/DancingGoat/appsettings.json`:
    `docker run -d --name xperience-sql -e ACCEPT_EULA=Y -e MSSQL_SA_PASSWORD=Pass@12345 -p 1433:1433 mcr.microsoft.com/mssql/server:2022-latest`
  - Local install: get its server name (e.g. `localhost\SQLEXPRESS`) and whether it uses Windows authentication.

Done when both versions match and the SQL Server accepts connections.

## 2. Get the license

Ask the user for the path to their Xperience license file, or check `XPERIENCE_LICENSE_FILE`. Treat the file as a credential: pass its path, never read, print, or copy its contents. Without a license the database is still created, but the live site returns errors and the administration hides custom applications until the license is added at first sign-in. Done when you have a path that exists, or the user chose to continue without one.

## 3. Create the database

Run `./scripts/Initialize-Database.ps1 -LicenseFile <path>`, adding `-ServerName <server>` and `-Username ""` for a local Windows-authentication SQL Server. Add `-Recreate` only after the user confirms dropping an existing database of the same name. The script creates the database with `kentico-xperience-dbmanager`, then moves the connection string and `CMSHashStringSalt` into DancingGoat's user secrets, leaving `examples/DancingGoat/appsettings.json` unchanged. Done when the script exits 0 and `git status --short` shows no change to `appsettings.json`.

## 4. Install dependencies and build

1. `dotnet tool restore` and `dotnet restore`
2. `npm ci` in each `src/*/Client` folder and in `tests/e2e`
3. `npm run install:browsers` in `tests/e2e`
4. `dotnet build`

Done when all four exit 0.

## 5. Offer Aspire

If the `aspire` CLI is installed (`aspire --version`), tell the user `aspire run` starts DancingGoat, the admin client dev server, and Mailpit together, using the database from step 3. Mention that `aspire agent init` installs Aspire's agent skills but also adds Aspire telemetry hooks to their global agent settings unless `ASPIRE_CLI_TELEMETRY_OPTOUT=true` is set; run it only if the user asks. Done when the user has been told.

## 6. Verify

Run `dotnet run --project examples/DancingGoat --no-build -- --kxp-db-status --format json`. Done when `state` is `Ready`. For any other state, follow its `message`.

## 7. Report

Tell the user:

- the site URL (`applicationUrl` in `examples/DancingGoat/Properties/launchSettings.json`) and the administration at `<url>/admin`, user `administrator`, password `Pass@12345` (or `XPERIENCE_ADMIN_PASSWORD`)
- whether the license was installed
- how to work on the admin client: `aspire run`, or `npm start` in `src/*/Client` (Proxy mode) alongside `dotnet run --project examples/DancingGoat`
- how to run e2e tests: `tests/e2e/README.md`
