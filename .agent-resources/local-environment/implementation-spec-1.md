# Slice 1 – Database init script

## Scope

- `scripts/Initialize-Database.ps1`: wraps `kentico-xperience-dbmanager` (run from `examples/DancingGoat`, so it updates that project's `appsettings.json`).
  - Defaults from `CMSConnectionString`: Data Source, Initial Catalog, User ID / Password (Windows authentication when `Integrated Security=True` or `-Username ""`).
  - `-AdminPassword` (default `XPERIENCE_ADMIN_PASSWORD` or `Pass@12345`), `-LicenseFile` (default `XPERIENCE_LICENSE_FILE`; warns and continues when missing), `-Recreate`.
- `docs/Contributing-Setup.md` Database Setup uses the script.

## Findings

- `dbmanager` writes the connection string (with the given database name) and a new `CMSHashStringSalt` into `appsettings.json`, and drops the final newline.
- `dbmanager` options (31.9.3): `-s`, `-d`, `-u`, `-p`, `-a`, `--hash-string-salt`, `--license-file`, `--recreate-existing-database`, `--use-existing-database`, `--connection-timeout`, `--sample-website-domain`, `--sample-email-service-domain`, `--instance-friendly-name`.
- The template's DancingGoat `UserSecretsId` was the Kentico template's generated GUID, shared with other local projects' user secrets (which override `appsettings.json`). Fixed on `committed-projects` (`e24a428`).

## Verification

- Created `init-probe` on Docker SQL Server 2022 (`localhost,1433`, `sa`) with `-Recreate` and a missing license path: warning, exit 0, database ready.
