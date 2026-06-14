# Release Process

The project does not have a release script yet. When one is added, it should produce a Factorio-compatible archive named:

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

## Pre-Release Checks

- Verify `info.json` name and version.
- Run available fast checks from `docs/testing.md`.
- Load the exact packaged mod in Factorio.
- Confirm the package does not include development-only documentation or local artifacts.
