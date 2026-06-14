# Behaviour

- Read `docs/no-aquilo-design.md` before implementing gameplay changes.
- Repository language is English for code, identifiers, comments, configuration, and developer documentation.
- `docs/no-aquilo-design.md` is intentionally German because it is the initial user-facing design document requested for this project.
- The mod's core promise is that Aquilo is not reachable or presented as part of Space Age progression. Do not reintroduce Aquilo as a required destination.
- When removing Aquilo, audit progression gates, space connections, item `default_import_location` values, technology unlocks, recipe `surface_conditions`, tips, locale strings, and Factoriopedia-facing text together.
- Avoid broad string-based deletion. Patch known Space Age prototypes explicitly and fail clearly when required prototypes are missing.
- Keep `docs/` and `testcases.md` current when gameplay, progression, packaging, or validation workflow changes.
- Prefer a data-stage-only implementation unless a runtime feature is clearly needed. This mod should primarily patch prototypes in `data.lua`, `data-updates.lua`, and `data-final-fixes.lua`.
- Use tabs for Lua indentation, following the local Factorio modding convention from nearby projects.
- Full validation requires loading the mod in Factorio. Lua syntax checks are useful but do not prove data-stage correctness.

# Project Overview

No Aquilo is a Factorio 2.0 Space Age mod. It removes Aquilo from the playable progression and relocates Aquilo-dependent resources and late-game production to the remaining planets.

The intended resource split is:

- Fulgora supplies lithium through late scrap recycling and lithium recovery.
- Vulcanus supplies fluorite as a new ore used for fluorine extraction.
- Gleba supplies spoilage for ammonia synthesis.
- Cryogenic, quantum, fusion, foundation, railgun, and promethium progression must remain reachable without visiting Aquilo.

# Documentation Index

- `docs/index.md`: Documentation entry point.
- `docs/no-aquilo-design.md`: German design document, including current progression decisions, risks, developer notes, open checks, and creative alternatives.
- `docs/testing.md`: Validation strategy and smoke-test workflow.
- `docs/release.md`: Packaging notes for Factorio-compatible ZIPs.
- `testcases.md`: Functional scenarios that should be checked before considering a version playable.
- `README.md`: English project entry point for maintainers.

# Glossary

- Aquilo: Space Age's original cold late-game planet. This mod removes it from reachable progression.
- Cryogenic chain: Recipes and technologies around lithium, fluoroketone, cryogenic science, quantum processors, fusion, foundation, and railguns.
- Fluorite: New Vulcanus ore proposed by this mod as the non-Aquilo source for fluorine.
- Lithium recovery: Fulgora-based replacement for Aquilo lithium sources.
- Solar system edge: Late space destination that must receive a new route because the original route starts from Aquilo.
