# Naming

`<Name>` is one PascalCase identifier (`CoolThing`). `<name>` is its kebab-case form (`cool-thing`; acronyms stay together: `MCPTools` → `mcp-tools`, `E2ETesting` → `e2e-testing`). `Rename-Template.ps1 -Preview` prints every derived name.

## Families

| Family | .NET name | Repository | Admin module key | Product name |
| --- | --- | --- | --- | --- |
| Kentico (fully supported) | `Kentico.Xperience.<Name>` | `Kentico/xperience-by-kentico-<name>` | `kentico-xperience-<name>-admin` | `Xperience by Kentico: <Display Name>` |
| Labs | `Kentico.Xperience.Labs.<Name>` | `Kentico/xperience-by-kentico-<name>` | `kentico-xperience-labs-<name>-admin` | `Xperience by Kentico Labs: <Display Name>` |
| Community | `XperienceCommunity.<Name>` | `<owner>/<any slug>` (default `xperience-community-<name>`) | `xperience-community-<name>-admin` | `Xperience Community: <Display Name>` |

The family sets the support policy. **Example** is a separate choice (`-Example`): the repository is example source code, not a published library, under any family. Example naming is the family's, except Labs examples put `labs` in the repository: `Kentico/xperience-by-kentico-labs-<name>`.

`<Display Name>` is the human-readable name with spaces (`Cool Thing`). The product name is the README `#` heading and the `<Product>` of each packable project (`.Admin` appends ` administration`). `Rename-Template.ps1 -DisplayName` writes both.

## Projects

| Project | Name | Purpose |
| --- | --- | --- |
| Core | `<.NET name>` | services, APIs, no admin UI |
| Admin | `<.NET name>.Admin` | admin UI extensions and client module; references core |
| Tests | `<.NET name>.Tests` | NUnit; references core |
| Sample | `DancingGoat` | always keeps this name |

Any project with admin UI extensions ends in `.Admin`, and its client module key ends in `-admin`.

## Admin client module

The module key is `<org>-<project>`. Four places must agree on `<org>` and `<project>`:

- `.Admin` csproj: `<AdminOrgName>` and `AdminClientPath` `<ProjectName>`
- admin module class: `RegisterClientModule("<org>", "<project>")`
- `Client/webpack.config.js`: `orgName`, `projectName`
- `UIApplication` template paths: `@<org>/<project>/<TemplateName>`

The full key appears in `Client/package.json` `name` and in `CMSAdminClientModuleSettings` in `examples/DancingGoat/appsettings.Development.json`.

## Template tokens

`Rename-Template.ps1` replaces these, most specific first. Any leftover `repotemplate`, `repo-template`, or `repo template` (any case) is a setup failure.

| Token | Becomes |
| --- | --- |
| `Kentico/xperience-by-kentico-repotemplate` | `<owner>/<slug>` |
| `xperience-by-kentico-repotemplate` | `<slug>` (also the local database name) |
| `kentico-xperience-repotemplate-admin` | admin module key |
| `kentico` + `xperience-repotemplate-admin` | admin `<org>` + `<project>` |
| `Kentico.Xperience.RepoTemplate` | .NET name (`Kentico-Xperience-RepoTemplate` dashed form in Azure DevOps artifacts; lowercase in lock files) |
| `Xperience by Kentico: Repo Template` | product name |
| `Repo Template` | `<Display Name>` |
| `RepoTemplate` | `<Name>` |
| `repotemplate` | `<name>` |
