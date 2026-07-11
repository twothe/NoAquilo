-- Enforces the complete No Aquilo progression contract after every mod has patched prototypes.
local helpers = require("prototypes.helpers")

local function fail(message)
	error("No Aquilo validation failed: " .. message)
end

local function assert_absent(prototype_type, name)
	if data.raw[prototype_type] and data.raw[prototype_type][name] then
		fail("prototype '" .. prototype_type .. "." .. name .. "' must not remain in normal progression.")
	end
end

local function assert_no_technology_reference_to_aquilo()
	if data.raw.technology["planet-discovery-aquilo"] then
		fail("technology 'planet-discovery-aquilo' still exists.")
	end

	for technology_name, technology in pairs(data.raw.technology or {}) do
		for _, prerequisite in pairs(technology.prerequisites or {}) do
			if prerequisite == "planet-discovery-aquilo" then
				fail("technology '" .. technology_name .. "' still requires planet-discovery-aquilo.")
			end
		end

		for _, effect in pairs(technology.effects or {}) do
			if effect.type == "unlock-space-location" and effect.space_location == "aquilo" then
				fail("technology '" .. technology_name .. "' still unlocks Aquilo.")
			end
		end
	end
end

local function assert_no_aquilo_default_imports()
	for prototype_type, prototypes in pairs(data.raw) do
		for prototype_name, prototype in pairs(prototypes) do
			if prototype.default_import_location == "aquilo" then
				fail("prototype '" .. prototype_type .. "." .. prototype_name .. "' still imports from Aquilo.")
			end
		end
	end
end

local function assert_unit(technology_name, expected_count)
	local technology = helpers.require_raw("technology", technology_name)
	local unit = technology.unit
	if not unit then
		fail("technology '" .. technology_name .. "' has no science unit.")
	end
	if unit.count ~= expected_count then
		fail("technology '" .. technology_name .. "' has count " .. tostring(unit.count) .. " instead of " .. tostring(expected_count) .. ".")
	end
	if unit.time ~= 60 then
		fail("technology '" .. technology_name .. "' has time " .. tostring(unit.time) .. " instead of 60.")
	end

	local expected = {}
	for _, ingredient in pairs(helpers.standard_science_pack_unit) do
		expected[ingredient[1]] = true
	end

	for _, ingredient in pairs(unit.ingredients or {}) do
		local science_pack = ingredient[1] or ingredient.name
		local amount = ingredient[2] or ingredient.amount
		if not expected[science_pack] then
			fail("technology '" .. technology_name .. "' uses unexpected science pack '" .. tostring(science_pack) .. "'.")
		end
		if amount ~= 1 then
			fail("technology '" .. technology_name .. "' uses " .. tostring(amount) .. " of science pack '" .. science_pack .. "' instead of 1.")
		end
		expected[science_pack] = nil
	end

	for missing_science_pack in pairs(expected) do
		fail("technology '" .. technology_name .. "' is missing science pack '" .. missing_science_pack .. "'.")
	end
end

local function assert_recipe_unlocked_by(technology_name, recipe_name)
	local technology = helpers.require_raw("technology", technology_name)
	for _, effect in pairs(technology.effects or {}) do
		if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
			return
		end
	end
	fail("technology '" .. technology_name .. "' does not unlock recipe '" .. recipe_name .. "'.")
end

local function assert_recipe_has_no_technology_effect(recipe_name)
	for technology_name, technology in pairs(data.raw.technology or {}) do
		for _, effect in pairs(technology.effects or {}) do
			if effect.recipe == recipe_name then
				fail("removed recipe '" .. recipe_name .. "' is still referenced by technology '" .. technology_name .. "'.")
			end
		end
	end
end

local function assert_recipe_has_no_surface_conditions(recipe_name)
	local recipe = helpers.require_raw("recipe", recipe_name)
	if recipe.surface_conditions then
		fail("recipe '" .. recipe_name .. "' still has surface_conditions.")
	end
end

local function assert_hidden_from_factoriopedia(prototype_type, prototype_name)
	local prototype = helpers.require_raw(prototype_type, prototype_name)
	if not prototype.hidden_in_factoriopedia then
		fail("prototype '" .. prototype_type .. "." .. prototype_name .. "' is still visible in Factoriopedia.")
	end
end

local function assert_recipe_categories(recipe_name, expected_categories)
	local recipe = helpers.require_raw("recipe", recipe_name)
	local actual_categories = {}
	for _, category in pairs(recipe.categories or {}) do
		actual_categories[category] = true
	end

	for _, expected_category in pairs(expected_categories) do
		if not actual_categories[expected_category] then
			fail("recipe '" .. recipe_name .. "' is missing category '" .. expected_category .. "'.")
		end
		actual_categories[expected_category] = nil
	end

	for unexpected_category in pairs(actual_categories) do
		fail("recipe '" .. recipe_name .. "' uses unexpected category '" .. unexpected_category .. "'.")
	end
end

local function assert_recipe_ingredient(recipe_name, ingredient_type, ingredient_name, expected_amount)
	local recipe = helpers.require_raw("recipe", recipe_name)
	for _, ingredient in pairs(recipe.ingredients or {}) do
		if ingredient.type == ingredient_type and ingredient.name == ingredient_name and ingredient.amount == expected_amount then
			return
		end
	end
	fail("recipe '" .. recipe_name .. "' is missing ingredient " .. expected_amount .. " " .. ingredient_name .. ".")
end

local function assert_recipe_entry_count(recipe_name, field_name, expected_count)
	local recipe = helpers.require_raw("recipe", recipe_name)
	local actual_count = #(recipe[field_name] or {})
	if actual_count ~= expected_count then
		fail("recipe '" .. recipe_name .. "' has " .. actual_count .. " " .. field_name .. " entries instead of " .. expected_count .. ".")
	end
end

local function assert_recipe_result(recipe_name, result_type, result_name, expected_amount)
	local recipe = helpers.require_raw("recipe", recipe_name)
	for _, result in pairs(recipe.results or {}) do
		if result.type == result_type and result.name == result_name and result.amount == expected_amount then
			return
		end
	end
	fail("recipe '" .. recipe_name .. "' is missing result " .. expected_amount .. " " .. result_name .. ".")
end

local function assert_recipe_independent_probability_result(recipe_name, result_type, result_name, expected_probability)
	local recipe = helpers.require_raw("recipe", recipe_name)
	for _, result in pairs(recipe.results or {}) do
		if result.type == result_type and result.name == result_name and result.independent_probability == expected_probability then
			return
		end
	end
	fail("recipe '" .. recipe_name .. "' is missing independent-probability result " .. result_name .. " at " .. tostring(expected_probability) .. ".")
end

local function assert_exact_prerequisites(technology_name, expected_prerequisites)
	local technology = helpers.require_raw("technology", technology_name)
	local actual_prerequisites = {}
	for _, prerequisite in pairs(technology.prerequisites or {}) do
		if actual_prerequisites[prerequisite] then
			fail("technology '" .. technology_name .. "' repeats prerequisite '" .. prerequisite .. "'.")
		end
		actual_prerequisites[prerequisite] = true
	end

	for _, prerequisite in pairs(expected_prerequisites) do
		if not actual_prerequisites[prerequisite] then
			fail("technology '" .. technology_name .. "' is missing prerequisite '" .. prerequisite .. "'.")
		end
		actual_prerequisites[prerequisite] = nil
	end

	for unexpected_prerequisite in pairs(actual_prerequisites) do
		fail("technology '" .. technology_name .. "' has unexpected prerequisite '" .. unexpected_prerequisite .. "'.")
	end
end

assert_no_technology_reference_to_aquilo()
assert_absent("space-connection", "gleba-aquilo")
assert_absent("space-connection", "fulgora-aquilo")
assert_absent("space-connection", "aquilo-solar-system-edge")
helpers.require_raw("space-connection", "solar-system-edge-shattered-planet")

local edge_connection = helpers.require_raw("space-connection", "fulgora-solar-system-edge")
if edge_connection.from ~= "fulgora" or edge_connection.to ~= "solar-system-edge" or edge_connection.length ~= 150000 then
	fail("fulgora-solar-system-edge has incorrect endpoints or length.")
end
if not edge_connection.asteroid_spawn_definitions or not edge_connection.asteroid_spawn_definitions[1] then
	fail("fulgora-solar-system-edge has no asteroid spawn definitions.")
end
for _, icon_layer in pairs(edge_connection.icons or {}) do
	if icon_layer.icon and string.find(icon_layer.icon, "aquilo", 1, true) then
		fail("fulgora-solar-system-edge still uses an Aquilo icon layer.")
	end
end

assert_no_aquilo_default_imports()

local lithium_processing = helpers.require_raw("technology", "lithium-processing")
if lithium_processing.research_trigger then
	fail("lithium-processing still has a research trigger.")
end
assert_unit("lithium-processing", 500)
assert_recipe_unlocked_by("lithium-processing", "lithium-plate")
assert_recipe_unlocked_by("lithium-processing", "scrap-lithium-recycling")
assert_exact_prerequisites("lithium-processing", {"planet-discovery-fulgora"})

assert_unit("ammonia-synthesis", 500)
assert_unit("fluorine-processing", 500)
assert_unit("lithium-recovery", 2000)
assert_exact_prerequisites("ammonia-synthesis", {"metallurgic-science-pack", "agricultural-science-pack", "electromagnetic-science-pack"})
assert_exact_prerequisites("fluorine-processing", {"metallurgic-science-pack", "agricultural-science-pack", "electromagnetic-science-pack"})
assert_exact_prerequisites("lithium-recovery", {"lithium-processing", "ammonia-synthesis", "fluorine-processing"})
assert_exact_prerequisites("cryogenic-plant", {"lithium-processing", "ammonia-synthesis", "fluorine-processing"})

local edge_discovery = helpers.require_raw("technology", "stellar-discovery-solar-system-edge")
assert_exact_prerequisites("stellar-discovery-solar-system-edge", {"fusion-reactor", "railgun"})
local unlocks_solar_system_edge = false
for _, effect in pairs(edge_discovery.effects or {}) do
	if effect.type == "unlock-space-location" and effect.space_location == "solar-system-edge" then
		unlocks_solar_system_edge = true
	end
end
if not unlocks_solar_system_edge then
	fail("technology 'stellar-discovery-solar-system-edge' does not unlock solar-system-edge.")
end

assert_recipe_unlocked_by("ammonia-synthesis", "ammonia-synthesis")
assert_recipe_unlocked_by("fluorine-processing", "fluorine-extraction")
assert_recipe_unlocked_by("lithium-recovery", "lithium-recovery")

for _, recipe_name in pairs({"ammonia-synthesis", "fluorine-extraction", "lithium-recovery"}) do
	assert_recipe_categories(recipe_name, {"chemistry", "cryogenics"})
end

for _, removed_recipe_name in pairs({"ammoniacal-solution-separation", "solid-fuel-from-ammonia", "ammonia-rocket-fuel", "ice-platform", "lithium"}) do
	local recipe = helpers.require_raw("recipe", removed_recipe_name)
	if not recipe.hidden then
		fail("removed recipe '" .. removed_recipe_name .. "' is not hidden.")
	end
	assert_hidden_from_factoriopedia("recipe", removed_recipe_name)
	helpers.assert_recipe_has_no_unlock(removed_recipe_name)
	assert_recipe_has_no_technology_effect(removed_recipe_name)
end

for _, recipe_name in pairs({"cryogenic-science-pack", "cryogenic-plant", "quantum-processor", "fusion-reactor", "fusion-generator"}) do
	assert_recipe_has_no_surface_conditions(recipe_name)
end

local promethium_surface_conditions = helpers.require_raw("recipe", "promethium-science-pack").surface_conditions or {}
if #promethium_surface_conditions ~= 1
	or promethium_surface_conditions[1].property ~= "gravity"
	or promethium_surface_conditions[1].min ~= 0
	or promethium_surface_conditions[1].max ~= 0 then
	fail("promethium-science-pack does not retain its exact Space-only gravity condition.")
end

for _, hidden_prototype in pairs(
{
	{"item", "ice-platform"},
	{"tile", "ice-platform"},
	{"fluid", "ammoniacal-solution"},
	{"fluid", "lithium-brine"},
	{"resource", "lithium-brine"},
	{"resource", "fluorine-vent"},
	{"planet", "aquilo"}
}) do
	assert_hidden_from_factoriopedia(hidden_prototype[1], hidden_prototype[2])
end

helpers.require_raw("item", "fluorite")
helpers.require_raw("resource", "fluorite")
helpers.require_raw("autoplace-control", "fluorite")
helpers.require_raw("noise-expression", "vulcanus_fluorite_probability")
helpers.require_raw("noise-expression", "vulcanus_fluorite_richness")

local vulcanus_map_gen_settings = helpers.require_raw("planet", "vulcanus").map_gen_settings
if not vulcanus_map_gen_settings
	or not vulcanus_map_gen_settings.autoplace_settings
	or not vulcanus_map_gen_settings.autoplace_settings.entity
	or not vulcanus_map_gen_settings.autoplace_settings.entity.settings
	or not vulcanus_map_gen_settings.autoplace_settings.entity.settings["fluorite"] then
	fail("Vulcanus map generation is missing entity autoplace settings for fluorite.")
end

assert_recipe_ingredient("ammonia-synthesis", "item", "spoilage", 2)
assert_recipe_ingredient("ammonia-synthesis", "item", "iron-ore", 2)
assert_recipe_ingredient("ammonia-synthesis", "fluid", "steam", 100)
assert_recipe_result("ammonia-synthesis", "fluid", "ammonia", 50)
assert_recipe_entry_count("ammonia-synthesis", "ingredients", 3)
assert_recipe_entry_count("ammonia-synthesis", "results", 1)

assert_recipe_ingredient("fluorine-extraction", "item", "fluorite", 10)
assert_recipe_ingredient("fluorine-extraction", "fluid", "sulfuric-acid", 100)
assert_recipe_result("fluorine-extraction", "fluid", "fluorine", 100)
assert_recipe_entry_count("fluorine-extraction", "ingredients", 2)
assert_recipe_entry_count("fluorine-extraction", "results", 1)

assert_recipe_ingredient("lithium-recovery", "item", "scrap", 50)
assert_recipe_ingredient("lithium-recovery", "fluid", "petroleum-gas", 50)
assert_recipe_result("lithium-recovery", "item", "lithium", 10)
assert_recipe_entry_count("lithium-recovery", "ingredients", 2)
assert_recipe_entry_count("lithium-recovery", "results", 1)
assert_recipe_independent_probability_result("scrap-lithium-recycling", "item", "lithium", 0.01)

assert_absent("tips-and-tricks-item", "aquilo-briefing")
assert_absent("tips-and-tricks-item", "heating-mechanics")
assert_absent("change-surface-achievement", "visit-aquilo")

local main_menu_simulations = helpers.require_raw("utility-constants", "default").main_menu_simulations or {}
if main_menu_simulations.aquilo_send_help or main_menu_simulations.aquilo_starter then
	fail("Aquilo main menu simulations are still registered.")
end
