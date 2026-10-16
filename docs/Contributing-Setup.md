# Contributing Setup

---This documents the steps a maintainer or developer would follow to work on the library in their development environment---

## Required Software

The requirements to setup, develop, and build this project are listed below.

### .NET Runtime

.NET SDK 10.0 or newer

- <https://dotnet.microsoft.com/en-us/download/dotnet/10.0>
- See `global.json` file for specific SDK requirements

### Node.js Runtime

- [Node.js](https://nodejs.org/en/download) LTS or newer
- [NVM for Windows](https://github.com/coreybutler/nvm-windows) or [NVM for macOS](https://github.com/nvm-sh/nvm) to manage multiple installed versions of Node.js
- See `engines` in `src/Kentico.Xperience.RepoTemplate.Admin/Client/package.json` for specific version requirements

### Database

SQL Server 2019 or newer compatible database

- [SQL Server Linux](https://learn.microsoft.com/en-us/sql/linux/install-upgrade/setup?view=sql-server-ver15)

## Sample Project

### Database Setup

Running the sample project requires an Xperience by Kentico database. AI agents can do the whole local setup (SQL Server, database, dependencies, verification) with the `setup-local` skill. To create the database by hand, run from the repository root:

```powershell
./scripts/Initialize-Database.ps1
```

- Server, database (`xperience-by-kentico-repotemplate`), and SQL login come from `ConnectionStrings` in `examples/DancingGoat/appsettings.json`. The default targets a Docker SQL Server on `localhost,1433` with the `sa` login; for a locally installed SQL Server pass `-ServerName` (and `-Username ""` for Windows authentication).
- The `administrator` account password is `Pass@12345`, or the `XPERIENCE_ADMIN_PASSWORD` environment variable.
- Pass `-LicenseFile <path>` (or set `XPERIENCE_LICENSE_FILE`) to install your Xperience license. Without it, add the license when you first sign in to the administration.
- `-Recreate` drops and recreates an existing database.
- The script runs [`kentico-xperience-dbmanager`](https://docs.kentico.com/documentation/developers-and-admins/installation#create-the-project-database), which writes the connection string and a new `CMSHashStringSalt` to `examples/DancingGoat/appsettings.json`. Don't commit those changes.

### Run with Aspire

[Aspire](https://aspire.dev) starts everything together: DancingGoat, the admin client dev server (Proxy mode), and Mailpit for emails. Install the [Aspire CLI](https://aspire.dev/get-started/install-cli/), then from the repository root:

```powershell
aspire run
```

The dashboard links the live site and the administration. By default DancingGoat uses the database from `scripts/Initialize-Database.ps1`. To use a SQL Server container instead (Docker required; the database is created on first run), set `Sql:UseExistingServer` to `false` in `examples/AppHost` user secrets:

```powershell
dotnet user-secrets set "Sql:UseExistingServer" false --project examples/AppHost
```

Set `XPERIENCE_LICENSE_FILE` before `aspire run` to install the license into a new container database.

The root `.mcp.json` registers the Aspire MCP server (`aspire agent mcp`), so AI agents can list resources, read logs, and restart them. `aspire agent init` can also install Aspire's agent skills; note that it adds Aspire telemetry hooks to your global agent settings unless `ASPIRE_CLI_TELEMETRY_OPTOUT=true` is set.

### End-to-end tests

Playwright tests for the live site and the administration live in `tests/e2e`; they need a licensed database. See [`tests/e2e/README.md`](../tests/e2e/README.md).

## Development Workflow

1. Create a new branch with one of the following prefixes
   - `feat/` - for new functionality
   - `refactor/` - for restructuring of existing features
   - `fix/` - for bugfixes

1. Run `dotnet format` against the `Kentico.Xperience.RepoTemplate` solution

   > use `dotnet: format` VS Code task.

1. Commit changes, with a commit message preferably following the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/#summary) convention.

1. Once ready, create a PR on GitHub. The PR will need to have all comments resolved and all tests passing before it will be merged.
   - The PR should have a helpful description of the scope of changes being contributed.
   - Include screenshots or video to reflect UX or UI updates
   - Indicate if new settings need to be applied when the changes are merged - locally or in other environments
   - Use the `populate-pr-template` agent skill (`.claude/skills/populate-pr-template/SKILL.md`, works with
     both Copilot and Claude) to fill in `.github/PULL_REQUEST_TEMPLATE.md` from git diff and CI evidence
     instead of writing the description by hand.

1. This repository uses `lf` line endings for text files. EditorConfig and Git enforce this on all platforms; no Git line-ending override is needed.
