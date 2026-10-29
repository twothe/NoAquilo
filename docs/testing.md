# Testing

No Aquilo changes Space Age prototype data, so full validation requires loading the mod in Factorio. Syntax checks catch only malformed Lua.

The current validation baseline is Factorio/Space Age 2.1.23. Repeat the full engine checks after every Factorio update.

## Automated Windows Checks

Run with PowerShell 7:

```powershell
pwsh -File scripts/test-mod.ps1
# For a different installation:
pwsh -File scripts/test-mod.ps1 -FactorioPath 'C:\Factorio\bin\x64\factorio.exe'
```

The command packages the current sources, then tests the exact ZIP with Quality enabled and disabled. Each run uses a new directory under `_factorio-test/`, with isolated config, mods, saves, logs, and prototype dumps. It does not change the player's mod list or saves.

Checks include:

- Full data-stage load, the production progression assertions, and unused prototype property warnings.
- New-game creation and a 60-tick save reload/benchmark, without test instrumentation.
- A separate test-only mod exercising the engine-resolved Aquilo resource settings, retained Nauvis oil/Vulcanus fluorite/Fulgora scrap, and lithium research unlocks.
- Deterministic Vulcanus generation at seed `12345`, size `4096`, requiring nonzero fluorite and calcite.
- Internal Aquilo generation at seed `12345`, size `512`, requiring zero crude-oil, lithium-brine, and fluorine-vent entities and richness. Creating this hidden surface in a test does not add a player-accessible route.

`tests/runtime-contract` is never packaged. Its resource-control assertion fails against the original mod version 2.1.0 and passes against 2.2.0. The commands exercise the real mod and engine; they do not emulate prototype processing.

### Recorded validation: 2026-10-29

Mod 2.2.0 passed the above checks on Factorio/Space Age 2.1.23. The Vulcanus preview contained 38,993 fluorite entities with 200,539,999 total richness, and 124,044 calcite entities. All three removed Aquilo resource counts were zero. The graphical client also loaded, but automated UI access was denied, so direct GUI inspection remains open. These checks do not replace a complete progression playthrough or validate arbitrary overhaul combinations or existing Aquilo saves.

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
- Confirm Aquilo and the retained `ice-platform` tile are hidden from Factoriopedia.
- Confirm the Resources tab contains no Aquilo crude-oil, lithium-brine, or fluorine-vent controls, including after switching presets. Nauvis crude oil, Vulcanus fluorite, and Fulgora scrap must remain available.
- Confirm the data stage loads without missing prototype errors.
- Confirm technologies and recipes match `docs/no-aquilo-design.md`.
- Confirm the replacement recipes expose both the `chemistry` and `cryogenics` categories introduced by Factorio 2.1.
- Confirm the route from Fulgora to `solar-system-edge` exists and the original Aquilo routes do not.
- Confirm `stellar-discovery-solar-system-edge` unlocks the edge after Fusion Reactor and Railgun research.
- Confirm Vulcanus map generation produces `fluorite` deposits.

Example local commands with an isolated mod directory:

```bash
factorio.exe --mod-directory "<test-mods>" --disable-audio --dump-data --check-unused-prototype-data
factorio.exe --mod-directory "<test-mods>" --disable-audio --generate-map-preview "<out>/vulcanus-preview.png" --map-preview-planet vulcanus --map-preview-size 4096 --report-quantities fluorite,calcite
factorio.exe --mod-directory "<test-mods>" --disable-audio --create "<out>/no-aquilo-new-game.zip"
```

## Regression Notes

- Lua syntax checks do not validate Factorio data-stage APIs, `data.raw` shape, map-gen expressions, or recipe unlock behavior.
- Factorio 2.1 removed `RecipePrototype.category` and the combined `chemistry-or-cryogenics` category. Replacement recipes must use `categories = {"chemistry", "cryogenics"}`.
- Factorio 2.1 renamed independent product `probability` to `independent_probability`; the lithium recycling byproduct must use the new field.
- Space Age 2.1 moved recycling assets and its category to the required `recycler` mod; runtime assets must use the `__recycler__` namespace.
- Quality is only a recommended Space Age dependency in 2.1. No Aquilo must load with Quality disabled.
- Any patch that removes or hides prototypes must be tested in Factorio, because other prototypes can still hold references.
- Vulcanus resources need both `property_expression_names` and `autoplace_settings.entity.settings` entries; a load-only check is not enough to prove they spawn.
- Hiding a resource entity does not hide its separate `autoplace-control`. Hide the three known Aquilo controls explicitly and disable their planet defaults with `size = 0` and `richness = 0`. Keep `frequency = 1`: Aquilo noise divides by frequency, and zero causes `SpotNoise::region_size` compilation errors. Hiding controls alone also does not disable generation.
- `game.default_map_gen_settings` contains generic control defaults, not the effective planet settings. Check a generated planet surface's `map_gen_settings` to verify the settings actually used.
- Keep `testcases.md` synchronized with every meaningful progression or balance change.
