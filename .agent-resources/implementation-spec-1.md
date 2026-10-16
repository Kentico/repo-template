# Slice 1 – Baseline committed projects

## Scope

- `src/Kentico.Xperience.RepoTemplate` – core classlib, references `Kentico.Xperience.WebApp`, `AddRepoTemplate()` DI extension, `InternalsVisibleTo` tests.
- `src/Kentico.Xperience.RepoTemplate.Admin` – from `kentico-xperience-admin-sample` (31.9.2), references core. Module renamed from `Acme*`. Org `kentico`, project `xperience-repotemplate-admin` (module key `kentico-xperience-repotemplate-admin`). CR-style npm targets (Debug uses prebuilt `Client/dist`; other configs run `npm ci` + `npm run build`). Single-chunk webpack, dev certs, dev server port 3009, `typecheck` script. Drop `UserListExtender` sample.
- `tests/Kentico.Xperience.RepoTemplate.Tests` – NUnit, references core.
- `examples/DancingGoat` – from `kentico-xperience-sample-mvc` (31.9.2). Overlay: core ref, `.Admin` ref (unconditional; DancingGoat's `SeparatedAdmin` option is ignored), `AddRepoTemplate()`, system SMTP/email, Proxy mode for admin module, launchSettings without IIS and `launchBrowser=false`, connection string to `localhost,1433` DB `xperience-by-kentico-repotemplate`. Nested `Directory.Packages.props` removed; `.mcp.json` moved to root; `.github/skills` dup removed; dbmanager tool merged into root manifest.
- Root: net10, no repo-wide `RootNamespace`, `IsPackable=false` for tests/examples, sentinel URLs, CPM versions for all packages, lock files, slnx membership + `src/Kentico.Xperience.RepoTemplate.Libs.slnx`.
- CI: Node 24 setup + npm cache + typecheck. Azure DevOps: Core + Admin artifacts. VS Code tasks: new Client path. `.gitignore`: drop `App_Data/RepoTemplate` line.
- `AGENTS.md`: agents write plans/specs to `.agent-resources/`.

## Out of scope

- `Repository-Setup.ps1` and `setup-repo` skill (slices 2–3). Both are stale after this slice.
- README/docs rewrite.
