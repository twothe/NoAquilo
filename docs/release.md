# Release Process

Release builds are produced by `scripts/package-mod.sh` and by the GitHub Actions workflow in `.github/workflows/build-release.yml`.

The generated archive is named:

```text
<mod-name>_<version>.zip
```

The archive must contain one top-level folder named `<mod-name>_<version>` with the loadable mod files inside it.

## Packaging Rules

Exclude development-only files from release archives:

- `.git/`
- `.idea/`
- `.vscode/`
- `dist/`
- `docs/`
- `AGENTS.md`
- `testcases.md`
- `todo.md`
- release/check scripts
- temporary files

The package script copies only Factorio runtime paths, so development files are excluded by construction.

## Local Build

Run:

```bash
bash scripts/package-mod.sh
```

The output is written to `dist/<mod-name>_<version>.zip`.

## GitHub Actions

The workflow runs on every `push`, `pull_request`, and manual `workflow_dispatch`.

Every successful run uploads a Factorio-ready ZIP as a build artifact. Pushing a tag named `v<version>` where `<version>` matches `info.json` additionally creates or updates a GitHub Release and attaches the same ZIP.

## Pre-Release Checks

- Verify `info.json` name and version.
- Run available fast checks from `docs/testing.md`.
- Load the exact packaged mod in Factorio.
- Confirm the package does not include development-only documentation or local artifacts.
