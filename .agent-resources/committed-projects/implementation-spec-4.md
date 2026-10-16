# Slice 4 – `update-xperience` skill

## Scope

- `.claude/skills/update-xperience/scripts/Update-Xperience.ps1 [-Version x.y.z] [-Preview]`:
  - Current version = `Kentico.Xperience.WebApp` in `Directory.Packages.props`; target defaults to latest stable `Kentico.Xperience.Templates` (nuget.org flat container).
  - Installs templates for current, then target; generates pristine `kentico-xperience-sample-mvc` (and `kentico-xperience-admin-sample` for npm versions). Exit 104 (skipped `dotnet tool restore` post action) is accepted.
  - Normalizes both pristines: strips `Directory.Packages.props`, `.github`, `.config`, `.mcp.json`; pins `UserSecretsId`, ports, ManagementApi secret.
  - Three-way merge in a scratch git repo (`base` = current pristine, `ours` = `examples/DancingGoat`, `theirs` = target pristine; LF-normalized). Result replaces tracked `examples/DancingGoat` files. Exit 2 + file list on conflicts.
  - Bumps root `Directory.Packages.props` versions the target DancingGoat pins, `.config/dotnet-tools.json` tools, and admin `Client/package.json` `dependencies`/`devDependencies` shared with the admin sample (not `overrides`).
- `SKILL.md`: 9 steps – check state, pick version (+ changelog), run, compare `.mcp.json`, lock files, fix breaking changes, validate, docs, report (incl. `--kxp-update` for local DBs).
- `references/dancinggoat-overlay.md`: every repository change to DancingGoat, for conflict resolution.
- Template bumped 31.9.2 → 31.9.3 with the script (first real run).
- Survives `setup-repo` (no template tokens in the skill).

## Verification

- Real run 31.9.2 → 31.9.3 on the template: clean merge (only `Data/Template.zip` changed), locked restore, Release build, test, format pass.
- Scratch copy pretending 31.8.0 → 31.9.3 (236 template files changed): clean merge.
- Same with a deliberate local edit on a template-changed line in `AGENTS.md`: exit 2, conflict markers in `AGENTS.md` only.
