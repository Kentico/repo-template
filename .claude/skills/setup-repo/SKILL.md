---
name: setup-repo
description: Set up this repository template for a new Kentico Xperience integration, selecting the project family and main project template before generation.
---

## Purpose

Guide the setup from the initial project choices through generation, CPM migration, documentation cleanup, validation, and removal of the one-time setup script.

## Workflow

1. Begin by asking whether the initial .NET project needs Admin client asset customization. Then ask which project family applies:
   - **Xperience by Kentico fully supported integration**: repository name must be `Kentico.Xperience.<IntegrationName>`.
   - **Xperience by Kentico Labs project**: repository name must be `Kentico.Xperience.Labs.<IntegrationName>`.
   - **Xperience Community project**: repository name must be `XperienceCommunity.<IntegrationName>`.
2. Ask for `<IntegrationName>` if it is not already provided. Require a single valid .NET identifier with no spaces or periods, then construct the repository name from the selected family. Show the resulting repository and .NET project names and get user acceptance before changing files:
   - If Admin client asset customization is **yes**, append `.Admin` to the .NET project name only. Keep the repository name unchanged, and use the `kentico-xperience-admin-sample` template for the main .NET project.
   - If it is **no**, use the repository name as the .NET project name and use the `classlib` template for the main .NET project.
3. Confirm the current directory is the repository root and `Repository-Setup.ps1`, `Kentico.Xperience.RepoTemplate.slnx`, and `Directory.Packages.props` exist. Inspect `git status --short`; preserve existing user changes and do not overwrite unrelated work.
4. Check that `kentico-xperience-sample-mvc` and the selected main-project template are installed. Use `dotnet new list <template>` and inspect `dotnet new <template> --help` for the selected template's options. If a required template is unavailable, report the issue and stop before running setup.
5. Run `.\Repository-Setup.ps1 -ProjectName "<RepositoryName>"` from the repository root, adding `-AdminUiExtension` when Admin client asset customization is **yes**. Check the command's exit status and stop on failure. The script creates the main project and test project using the accepted names and template, keeps the solution and repository named `<RepositoryName>`, and always creates DancingGoat. Do not rerun the script after successful setup.
6. Inspect all generated project files, the root `Directory.Packages.props`, and applicable `Directory.Build.*` files. Ensure repo, project, assembly, namespace, solution, reference, and documentation names follow the accepted naming choices. Preserve the DancingGoat sample name. For the Admin route, search the generated Admin project code and assets for template placeholder values and replace them with accurate values derived from the accepted repository/project names. Do not leave obvious template placeholders; if a required value cannot be derived safely, report it for user input. Identify all package references and explicit package versions in the main project, test project, and DancingGoat project.
7. Consolidate every explicitly-versioned `PackageReference` from those projects into the root `Directory.Packages.props`:
   - Preserve existing package versions and properties.
   - Add or update one `<PackageVersion Include="..." Version="..." />` for each package that needs a version.
   - Remove `Version` attributes from the corresponding project `<PackageReference>` items while preserving other metadata.
   - Leave project references and framework references unchanged. Do not create nested `Directory.Packages.props` files or duplicate package versions.
   - Check inherited package references too, including those in `Directory.Build.props`, and ensure their package IDs have a central version.
8. Restore the renamed root solution so CPM issues are surfaced. Fix all package-version errors in the project files and central props, then restore again until it succeeds:
   `dotnet restore "<RepositoryName>.slnx"`
9. Build the solution without restoring, then format repository projects before finishing:
   - `dotnet build "<RepositoryName>.slnx" --no-restore`
   - `dotnet format "<RepositoryName>.slnx" --exclude ./examples/ --no-restore`
10. Review `README.md` and every Markdown file under `docs\`. Remove all template placeholders and setup instructions that no longer apply, and replace them with accurate project-specific documentation where the generated project gives enough context. Apply the accepted repo/project naming consistently across generated code and documentation. Do not delete useful general guidance or invent project-specific facts; preserve unresolved necessary content and report it for maintainer input.
11. Review the final diff and status. Confirm repository and .NET project names match the accepted choices, the correct main-project template was used, references and solution membership are correct, the main, test, and DancingGoat projects have no explicit package versions, package versions are centralized, and README/docs contain no template placeholders or obsolete setup instructions.
12. Once setup, restore, build, formatting, documentation cleanup, and final review all succeed, make removal of `Repository-Setup.ps1` the final setup change. It is a one-time template setup script and must not remain in the completed repository. Do not remove it if setup or validation failed.
13. Report the selected project family, Admin customization choice, resulting names, commands and results, and any remaining failure or documentation needing maintainer input without claiming setup succeeded.
