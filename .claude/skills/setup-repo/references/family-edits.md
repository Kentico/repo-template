# Family edits

Apply the rows for the selected family, plus the Example rows for an example repository, after `Rename-Template.ps1` succeeds. Where they conflict, the Example row wins. Every listed file is either edited as described or deleted.

## Publishing

| Family | Keep | Delete |
| --- | --- | --- |
| Kentico, Labs | `.azuredevops/`, `Directory.build.targets` (code signing), `azuresigntool` in `.config/dotnet-tools.json` | `.github/workflows/publish.yml` |
| Community | `.github/workflows/publish.yml` | `.azuredevops/`, `Directory.build.targets`, `azuresigntool` entry |
| Example (any family) | – | `.azuredevops/`, `Directory.build.targets`, `azuresigntool` entry, `.github/workflows/publish.yml`, `src/*.Libs.slnx` |

When `.azuredevops/` is deleted, also remove its file association in `.vscode/settings.json`. When `publish.yml` is kept, delete its header comment line about `.azuredevops/pipelines`.

Example: also set `<IsPackable>false</IsPackable>` in the root `Directory.Build.props` and remove the package-only metadata there (`PackageLicenseExpression`, `PackageProjectUrl`, `PackageReleaseNotes`, `PackageIcon`, `PackageReadmeFile`, `PackageTags`, the `logo.png` / `README.md` pack items, and the Release-only symbol package `PropertyGroup`).

Community: tell the maintainer to create a nuget.org Trusted Publishing policy for the repository and `publish.yml`, and set the `NUGET_USER` repository variable. Releases publish on GitHub release.

## Ownership

| Family | `Directory.Build.props` `Company` / `Authors` | `LICENSE.md` holder | `.github/CODEOWNERS` | `images/logo.png` |
| --- | --- | --- | --- | --- |
| Kentico, Labs | keep `Kentico Software` | keep | keep `@Kentico/platform-engineering` unless told otherwise | keep |
| Community | author name; remove `Trademark` | author name | `* @<owner>` | ask the author for an icon; keep only if they accept the Kentico logo |

## README support

| Family | Badge | Support section |
| --- | --- | --- |
| Kentico | 7-day bug-fix badge only | "Full support by 7-day bug-fix policy" + `SUPPORT.md#full-support` link |
| Labs | Kentico Labs badge only | "Kentico Labs limited support" + `SUPPORT.md#labs-limited-support` link |
| Community | none | community-maintained statement; issues on this repository; drop Kentico `SUPPORT.md` / `SECURITY.md` links |

Example (any family): the family's badge and support text apply. Describe the repository as example source code. Replace "Package Installation", "Quick Start", and the version matrix with a `## Running the Example` section (create the database per `docs/Contributing-Setup.md`, then `dotnet run --project examples/DancingGoat`, and the app URL from `launchSettings.json`). "Dependencies" lists what is needed to run it.

Community: point "Contributing" at `docs/Contributing-Setup.md` and this repository's issues instead of Kentico's `CONTRIBUTING.md` / `CODE_OF_CONDUCT`.

Keep the CI badge for every family.
