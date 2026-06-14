# Testing

No Aquilo changes Space Age prototype data, so full validation requires loading the mod in Factorio. Syntax checks catch only malformed Lua.

## Fast Checks

- Validate `info.json` with `jq . info.json`.
- Run a Lua compile check:

```bash
luac -p data.lua data-updates.lua data-final-fixes.lua prototypes/*.lua
```

- Inspect generated/changed prototype names against Factorio's loaded Space Age prototype names before patching them.

## Required Factorio Checks

- Start a new Space Age game with the mod enabled.
- Confirm Aquilo is not researchable, routable, or suggested as a logistics destination.
- Confirm the data stage loads without missing prototype errors.
- Confirm technologies and recipes match `docs/no-aquilo-design.md`.
- Confirm the route from Fulgora to `solar-system-edge` exists and the original Aquilo routes do not.
- Confirm Vulcanus map generation produces `fluorite` deposits.

Example local commands with an isolated mod directory:

```bash
factorio.exe --mod-directory "<test-mods>" --disable-audio --dump-data --check-unused-prototype-data
factorio.exe --mod-directory "<test-mods>" --disable-audio --generate-map-preview "<out>/vulcanus-preview.png" --map-preview-planet vulcanus --map-preview-size 4096 --report-quantities fluorite,calcite
factorio.exe --mod-directory "<test-mods>" --disable-audio --create "<out>/no-aquilo-new-game.zip"
```

## Regression Notes

- Lua syntax checks do not validate Factorio data-stage APIs, `data.raw` shape, map-gen expressions, or recipe unlock behavior.
- Any patch that removes or hides prototypes must be tested in Factorio, because other prototypes can still hold references.
- Vulcanus resources need both `property_expression_names` and `autoplace_settings.entity.settings` entries; a load-only check is not enough to prove they spawn.
- Keep `testcases.md` synchronized with every meaningful progression or balance change.
