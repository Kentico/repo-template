# Slice 5 – dependabot, security pin, AGENTS.md

## Scope

- `.github/dependabot.yml`: weekly NuGet (root, CPM), admin client npm, GitHub Actions; minor/patch grouped. Ignores `Kentico.Xperience.*`, `@kentico/*`, and React (must match the Xperience admin) – those move with the `update-xperience` skill.
- `Directory.Packages.props`: `CentralPackageTransitivePinningEnabled` + `System.Security.Cryptography.Pkcs` 10.0.13 pin (Xperience 31.9.3 brings vulnerable 10.0.0 via MimeKit / Microsoft.Data.SqlClient). Build now 0 warnings.
- `update-xperience` step 5: review transitive security pins after each update.
- `setup-repo` `remove-admin.md`: drop the dependabot npm entry.
- `AGENTS.md`: versions only in `Directory.Packages.props` + `--force-evaluate`; Kentico versions only via `update-xperience`; record DancingGoat overlay changes in `dancinggoat-overlay.md`.
