# Remove the `.Admin` project

Only when the project has no admin UI extensions. `<Admin>` is the renamed `.Admin` project folder under `src/`.

Done when every item below is removed or edited and `git grep --untracked -n -e "<.NET name>.Admin" -e "<admin module key>" -e "Client/" -- ":!.claude/skills/setup-repo"` finds nothing.

- `src/<Admin>/` folder
- root `.slnx` and `src/*.Libs.slnx`: the `<Admin>` project entry (`dotnet sln <file> remove <csproj>`)
- `examples/DancingGoat/DancingGoat.csproj`: the `<Admin>` `ProjectReference`
- `examples/DancingGoat/appsettings.Development.json`: the `CMSAdminClientModuleSettings` section
- `.github/workflows/ci.yml`: in `build_and_test`, the `Setup Node.js` and `Type-check admin client` steps and the npm build comment; in `e2e`, the admin `Client/package-lock.json` line of `cache-dependency-path` and the npm build comment
- `.azuredevops/pipelines/build-and-release.yml` (if present): the Node.js version + `UseNode` steps and the `Admin` artifact
- `.github/workflows/publish.yml` (if present): the same Node.js step
- `.github/dependabot.yml`: the `npm` entry
- `examples/AppHost/AppHost.cs`: the `admin-client` resource and its comment
- `.gitignore`: the `**/Client/dist/*` line
- `.github/PULL_REQUEST_TEMPLATE.md`: the `### Admin UI / Client` section
- `.vscode/tasks.json`: every task labelled `npm: ...`; `.vscode/settings.json`: the `eslint.workingDirectories` key (keep the JSON valid)
- `docs/Contributing-Setup.md`: the admin `Client/package.json` reference in the Node.js requirement (keep Node.js itself: `tests/e2e` needs it)
- `tests/e2e/admin/custom-template.spec.ts` and `tests/e2e/admin/customTemplatePage.ts` (the sample admin page they test is gone); keep the rest of `tests/e2e/admin` – admin sign-in and shell tests still apply to libraries without admin UI pages
- `tests/e2e/README.md`: the Proxy-mode `npm start` requirement
- README install command: the core package instead of `.Admin`

`Kentico.Xperience.Admin` stays in `Directory.Packages.props`: DancingGoat still references it.
