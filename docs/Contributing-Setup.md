# Contributing Setup

---This documents the steps a maintainer or developer would follow to work on the library in their development environment---

---Update the details for this project and delete the lines enclosed by three dashes---

## Required Software

If this repository contains a `docs/Development-Setup.md`, follow it for the sample application, database and tooling setup.

## Development Workflow

1. Create a new branch with one of the following prefixes
   - `feat/` - for new functionality
   - `refactor/` - for restructuring of existing features
   - `fix/` - for bugfixes

1. Commit changes, with a commit message preferably following the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/#summary) convention.

1. Once ready, create a PR on GitHub. The PR will need to have all comments resolved and all tests passing before it will be merged.
   - The PR should have a helpful description of the scope of changes being contributed.
   - Include screenshots or video to reflect UX or UI updates
   - Indicate if new settings need to be applied when the changes are merged - locally or in other environments

1. This repository is stored with `lf` line endings; `.gitattributes` and `.editorconfig` enforce it on every platform.
