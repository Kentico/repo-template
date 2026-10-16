# Remove the `.Admin` project

Only when the project has no admin UI extensions. `<Admin>` is the renamed `.Admin` project folder under `src/`.

Done when every item below is removed or edited and `git grep --untracked -n -e "<.NET name>.Admin" -e "<admin module key>" -e "Client/" -- ":!.claude/skills/setup-repo"` finds nothing.

- `src/<Admin>/` folder
- root `.slnx` and `src/*.Libs.slnx`: the `<Admin>` project entry (`dotnet sln <file> remove <csproj>`)
- `examples/DancingGoat/DancingGoat.csproj`: the `<Admin>` `ProjectReference`
- `examples/DancingGoat/appsettings.Development.json`: the `CMSAdminClientModuleSettings` section
- `.github/workflows/ci.yml`: the `Setup Node.js` and `Type-check admin client` steps, and the comment about the npm build
- `.azuredevops/pipelines/build-and-release.yml` (if present): the Node.js version + `UseNode` steps and the `Admin` artifact
- `.github/workflows/publish.yml` (if present): the same Node.js step
- `.github/dependabot.yml`: the `npm` entry
- `.gitignore`: the `**/Client/dist/*` line
- `.github/PULL_REQUEST_TEMPLATE.md`: the `### Admin UI / Client` section
- `.vscode/tasks.json`: every task labelled `npm: ...`; `.vscode/settings.json`: the `eslint.workingDirectories` key (keep the JSON valid)
- `docs/Contributing-Setup.md`: the Node.js requirement
- README install command: the core package instead of `.Admin`

`Kentico.Xperience.Admin` stays in `Directory.Packages.props`: DancingGoat still references it.
