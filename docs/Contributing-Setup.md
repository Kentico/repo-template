# Contributing Setup

---This documents the steps a maintainer or developer would follow to work on the library in their development environment---

---Update the details for this project and delete the lines enclosed by three dashes---

## Required Software

### .NET SDK

.NET SDK 10.0 or newer

- <https://dotnet.microsoft.com/en-us/download/dotnet/10.0>
- See `global.json` file for specific SDK requirements

### C# Editor

- VS Code / Visual Studio
- Cursor
- Rider

If this repository contains a `docs/Development-Setup.md`, follow it for the sample application, database and tooling setup.

## Adding Your Project

The template ships no projects. Create yours under `src/` (and tests under `tests/`), then:

1. Add it to both solution files: the root one, which CI builds, and `src/*.Libs.slnx`, which the release pipeline builds and packs.
1. Run `dotnet restore` and commit the generated `packages.lock.json`; CI restores with `--locked-mode`.
1. Run `dotnet format` before the first commit; `dotnet new` writes CRLF files on Windows and CI checks formatting with `--verify-no-changes`.

## Development Workflow

1. Create a new branch with one of the following prefixes
   - `feat/` - for new functionality
   - `refactor/` - for restructuring of existing features
   - `fix/` - for bugfixes

1. Commit changes, with a commit message preferably following the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/#summary) convention.

1. Run `dotnet restore` and commit the updated `packages.lock.json` files whenever package references change. CI rejects builds with missing or outdated lock files.

1. Once ready, create a PR on GitHub. The PR will need to have all comments resolved and all tests passing before it will be merged.
   - The PR should have a helpful description of the scope of changes being contributed.
   - Include screenshots or video to reflect UX or UI updates
   - Indicate if new settings need to be applied when the changes are merged - locally or in other environments

1. This repository is stored with `lf` line endings; `.gitattributes` and `.editorconfig` enforce it on every platform.
