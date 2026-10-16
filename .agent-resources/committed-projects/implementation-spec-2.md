# Slice 2 – Rename script + smoke CI job

## Scope

- `.claude/skills/setup-repo/scripts/Rename-Template.ps1` (`-Family Kentico|Labs|Community|Example -Name <PascalCase> [-RepoSlug] [-GitHubOrg]`):
  - Derives .NET name, repo slug, admin org/project, module key from family + name (kebab-case via PascalCase split, acronyms kept together: `MCPTools` → `mcp-tools`).
  - Replaces tokens case-sensitively, most-specific first, in tracked + untracked (non-ignored) text files. Lowercase `kentico.xperience.repotemplate` handled for NuGet lock files.
  - Renames files/folders containing `RepoTemplate`, deepest first.
  - Regenerates DancingGoat `UserSecretsId`, `CMSHashStringSalt`, ManagementApi secret (also `.mcp.json`), app port (40000–59999), admin client port (3010–3099).
  - Fails (exit 1) if `repotemplate`/`repo-template` remains in any processed file or path.
  - Skips `.agent-resources/` and `.claude/skills/setup-repo/`.
- CI `template_smoke` job: matrix over 4 families, rename → locked restore → Release build → test. Runs only when `github.repository == 'Kentico/repo-template'`.
- README template-info points to `setup-repo` skill; CI badge and `dotnet add package` use tokens.
- `Repository-Setup.ps1` removed.

## Out of scope

- Family-specific pruning (badges, authors, CODEOWNERS, Azure DevOps vs GitHub publish, `IsPackable` for Example) – slices 3 and 5.
- Resetting `.agent-resources/` in new repos – slice 3 skill.
