---
name: update-xperience
description: Update Xperience by Kentico to a newer version - bump Kentico NuGet and npm packages and regenerate the DancingGoat example from the new project template, keeping this repository's changes. Use when upgrading or refreshing Xperience, Kentico packages, or DancingGoat.
---

`scripts/Update-Xperience.ps1` does the mechanical work: it generates pristine DancingGoat projects for the current and target versions and three-way merges them with `examples/DancingGoat`, so template changes come in and this repository's changes stay. It also updates Kentico versions in `Directory.Packages.props`, `.config/dotnet-tools.json`, and admin `Client/package.json` files. Each step ends on its completion criterion.

## 1. Check the starting state

Run from the repository root. Done when `git status --short` is empty. If there are local changes, stop and ask the user how to proceed.

## 2. Pick the version

Run `./.claude/skills/update-xperience/scripts/Update-Xperience.ps1 [-Version <x.y.z>] -Preview`. Without `-Version` the target is the latest stable `Kentico.Xperience.Templates`. Done when the user accepts the current → target versions. Read the Xperience changelog for breaking changes between them (<https://docs.kentico.com/changelog>) and tell the user which apply.

## 3. Run the update

Run the same command without `-Preview`. Done when it exits 0, or exits 2 and you have resolved every conflicted file it lists: no `<<<<<<<`, `=======`, or `>>>>>>>` lines remain in `examples/DancingGoat`. Resolve conflicts with [references/dancinggoat-overlay.md](references/dancinggoat-overlay.md). The pristine projects and merge repository stay in the work folder the script prints; `git -C <work>/merge diff base theirs` shows exactly what the template changed.

## 4. Compare root files the template also ships

The script prints two paths from the target template:

- `.mcp.json`: add any MCP server it has that the root `.mcp.json` lacks, keeping the root's port and secret.
- DancingGoat skills: for each skill folder, bring its content into the root `.claude/skills/<name>/`, keeping the root's `description` and the line saying paths are relative to `examples/DancingGoat/`. A skill with no root copy is added the same way.

Done when every MCP server in the target file exists in the root file and every target skill body matches its root copy apart from those two lines.

## 5. Update lock files

- In each `src/*/Client` folder: `npm install --no-audit --no-fund`
- `dotnet tool restore`
- `dotnet restore --force-evaluate`, then `dotnet restore --locked-mode`

Done when the locked restore exits 0.

Then review the `Transitive security pins` group in `Directory.Packages.props`: for each pin, remove it, run `dotnet restore --force-evaluate` and `dotnet nuget why <root .slnx> <package>`, and keep the removal when the resolved version is at least the pinned one and restore reports no NU190x vulnerability warning; otherwise restore the pin. Done when every remaining pin is still needed.

## 6. Fix breaking changes

Build with `dotnet build --configuration Release --no-restore`. Fix every error in `src/` and `tests/` caused by the new version, guided by the changelog from step 2. Done when the build has no errors.

## 7. Validate

1. `dotnet test --configuration Release --no-build`
2. `dotnet format --no-restore --verify-no-changes`
3. In each `src/*/Client`: `npm run typecheck`

Done when all three pass.

## 8. Update docs

Set the minimum Xperience version in the `README.md` version matrix to the target version when the library now requires it (any `src/` change in step 6, or the user says so). Done when every Xperience version mentioned in `README.md` and `docs/` is intentional.

## 9. Report

List: current → target version, packages and tools changed, conflicts and how each was resolved, breaking changes fixed, validation results, and the maintainer's next step: update existing local databases with `dotnet run --project examples/DancingGoat -- --kxp-update` (see <https://docs.kentico.com/documentation/developers-and-admins/installation/update-xperience-by-kentico-projects>).
