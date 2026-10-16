# Slice 4 – Aspire AppHost

## Scope

- `examples/AppHost` (Aspire 13.6.1, `Aspire.AppHost.Sdk`), `aspire.config.json` at the root so `aspire run` works from there. Resources:
  - `mailpit` (CommunityToolkit 13.6.0); DancingGoat SMTP host/port injected
  - `dancinggoat` (launch profile port; dashboard links "Live site" and "Administration")
  - `admin-client` (`AddJavaScriptApp(..., "start").WithNpm(install: true)`, Proxy mode)
  - `Sql:UseExistingServer` (default `true`): DancingGoat uses its own user secrets (from `setup-local`)
  - `false`: persistent `sql` container with data volume + `database-init` executable (`Initialize-Database.ps1 -IfNotReady -SaveTo Salt`, SA password via environment variable, optional `XPERIENCE_LICENSE_FILE`); DancingGoat gets the connection string and waits for completion
- `Initialize-Database.ps1`: `-IfNotReady` (`--kxp-db-status` → skip when Ready, `--kxp-update` when behind), `-SaveTo UserSecrets|Salt|AppSettings|None`, `-HashStringSalt` (defaults to the salt already in DancingGoat user secrets, so dbmanager keeps one salt per machine), `XPERIENCE_SQL_PASSWORD`.
- `.mcp.json`: `aspire` MCP server (`aspire agent mcp`). Aspire skills are not committed (`aspire agent init` is the developer's choice; it adds global telemetry hooks).
- Rename: AppHost `UserSecretsId` and launch-profile ports randomized; tokens cover the database name and admin client path. `remove-admin.md` drops the `admin-client` resource.
- `MessagePack` 2.5.303 transitive pin (Aspire brings vulnerable 2.5.302). Dependabot groups `Aspire.*` packages.
- Docs: contributing "Run with Aspire", e2e README, `AGENTS.md`, `setup-local` step 5.

## Findings

- `localhost` makes SqlClient try `::1` first; Docker publishes on `127.0.0.1` only → 27 s timeouts. Use `EndpointProperty.IPV4Host`.
- Resource arguments are logged (dashboard and `aspire logs`); pass secrets as environment variables.
- `aspire agent init` writes telemetry hooks into global `~/.claude/settings.json` and `~/.copilot/hooks/` regardless of `--workspace-root`.
- CI keeps service containers + script (same as existing-server mode); the AppHost is built in CI as part of the solution.

## Verification

- Existing-server mode: `aspire start` → DancingGoat up 2.8 s, e2e 6/6.
- Container mode (fresh volume, license): database created 53 s, salt reused from user secrets, DancingGoat user secrets and `appsettings.json` unchanged, e2e 6/6; restart skips init (DancingGoat up 5 s).
- Community rename on a scratch copy: AppHost tokens, ports, `UserSecretsId` replaced; restore/build/test pass.
