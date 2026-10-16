---
name: setup-repo
description: Set up a repository created from the Kentico repo template - choose the family (Kentico, Labs, Community), library or example, and name, then rename, prune, and rewrite docs. Use once, right after the repository is created.
---

Turns the template's placeholder projects (`Kentico.Xperience.RepoTemplate*`) into the new project. Names come from [references/naming.md](references/naming.md). Each step ends on its completion criterion; move on only when it holds.

## 1. Check the starting state

Run from the repository root. Done when `Kentico.Xperience.RepoTemplate.slnx` exists and `git status --short` is empty. If there are local changes, stop and ask the user how to proceed.

## 2. Agree on names

Collect from the user:

- **Family**: Kentico (fully supported), Labs, or Community
- **Example**: is this example source code rather than a published library?
- **Name**: one PascalCase .NET identifier (`CoolThing`)
- **Display name**: human-readable (`Cool Thing`)
- **Description**: one sentence on what the library does
- **Admin UI**: does it extend the Xperience administration? (keeps or removes the `.Admin` project)
- Community only: GitHub owner, author name, repository slug if not `xperience-community-<name>`

Run `./.claude/skills/setup-repo/scripts/Rename-Template.ps1 -Family <Family> -Name <Name> -DisplayName "<Display name>" [-Example] [-GitHubOrg <owner>] [-RepoSlug <slug>] -Preview`. Show its output. Done when the user accepts every name.

## 3. Rename

Run the same command without `-Preview`. Done when it exits 0. It deletes the template-only `.github/workflows/template-smoke.yml`, replaces tokens (including product names), renames files and folders, regenerates DancingGoat secrets and ports, sets the `LICENSE.md` year, and exits 1 listing any leftover token. On failure, fix the listed lines by hand; a rerun is safe but regenerates secrets and ports.

## 4. Apply family edits

Follow the selected family's rows, plus the Example rows for an example, in [references/family-edits.md](references/family-edits.md). Done when every listed file for that family is edited or deleted.

## 5. Remove the admin project (no admin UI only)

Follow [references/remove-admin.md](references/remove-admin.md). Done when its grep check finds nothing.

## 6. Set descriptions

Replace `---Package description---` in each `src/` csproj `<Description>` and in `Client/package.json` `description` with the user's description. Done when `git grep --untracked -n -e "---Package description---" -- ":!.claude/skills/setup-repo"` finds nothing.

## 7. Remove template-only material

- the `---Template info---` section at the top of `README.md` (through the line before `# `)
- every feature folder in `.agent-resources/` (the template's own planning), leaving only an empty `.agent-resources/.gitkeep`; the new repository's features get their own folders later (see `AGENTS.md`)

Done when `README.md` starts with the `# ` heading and `.agent-resources/` holds only `.gitkeep`.

## 8. Rewrite docs

Lines enclosed in `---` in `README.md` and `docs/*.md` are instructions to the writer. Follow each, then delete it.

- README: display name heading, family badge and support text, description, version matrix (`>= <Kentico.Xperience.* version in Directory.Packages.props>` → `1.0.0`), install command for the `.Admin` package when kept (it depends on core), otherwise core
- `docs/Contributing-Setup.md`: real solution name, database name (`Initial Catalog` in `examples/DancingGoat/appsettings.json`), Node.js requirement only if `.Admin` remains
- `docs/Usage-Guide.md`: keep the heading; fill only what the code supports

Write only facts the code or the user supplied. Done when no line in `README.md` or `docs/` starts with `---`, except placeholders that need maintainer input, which you list for step 11.

## 9. Validate

Run, in order, each passing before the next:

1. `dotnet restore --force-evaluate` (lock files change when projects were removed), then `dotnet restore --locked-mode`
2. `dotnet build --configuration Release --no-restore`
3. `dotnet test --configuration Release --no-build`
4. `dotnet format --no-restore --verify-no-changes`
5. `git grep --untracked -n -i -E "repo[- ]?template" -- ":!.claude/skills/setup-repo"` finds nothing

Done when all five pass. On failure fix the cause and restart from 1.

## 10. Remove this skill

Delete `.claude/skills/setup-repo/` only after step 9 passes. Done when the folder is gone.

## 11. Report

List: family, library or example, every resulting name, admin project kept or removed, files deleted in steps 4, 5, and 7, validation results, remaining placeholders, and the maintainer's next steps:

- create the local environment with the `setup-local` skill
- add the Xperience license key as the `XPERIENCE_LICENSE_KEY` repository secret and Dependabot secret, so the `e2e` CI job runs (it is skipped without it)
- Community: Trusted Publishing policy on nuget.org and the `NUGET_USER` repository variable; package icon
- review `.github/CODEOWNERS`
