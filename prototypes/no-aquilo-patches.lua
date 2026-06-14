local helpers = require("prototypes.helpers")

local function remove_aquilo_space_unlocks()
	for _, technology in pairs(data.raw.technology or {}) do
		local effects = technology.effects
		if effects then
			for index = #effects, 1, -1 do
				local effect = effects[index]
				if effect.type == "unlock-space-location" and effect.space_location == "aquilo" then
					table.remove(effects, index)
				end
			end
		end
	end
end

local function patch_space_connections()
	local old_edge_connection = helpers.require_raw("space-connection", "aquilo-solar-system-edge")
	local new_edge_connection = table.deepcopy(old_edge_connection)

	new_edge_connection.name = "fulgora-solar-system-edge"
	new_edge_connection.from = "fulgora"
	new_edge_connection.to = "solar-system-edge"
	new_edge_connection.order = "h"
	new_edge_connection.length = 150000
	new_edge_connection.icons =
	{
		{icon = "__space-age__/graphics/icons/planet-route.png"},
		{
			icon = "__space-age__/graphics/icons/fulgora.png",
			icon_size = 64,
			scale = 0.333,
			shift = {-6, -6}
		},
		{
			icon = "__space-age__/graphics/icons/solar-system-edge.png",
			icon_size = 64,
			scale = 0.333,
			shift = {6, 6}
		}
	}

	data.raw["space-connection"]["fulgora-solar-system-edge"] = new_edge_connection
	data.raw["space-connection"]["gleba-aquilo"] = nil
	data.raw["space-connection"]["fulgora-aquilo"] = nil
	data.raw["space-connection"]["aquilo-solar-system-edge"] = nil
end

local function patch_lithium_processing()
	local technology = helpers.require_raw("technology", "lithium-processing")

	helpers.set_recipe_unlocks(technology, {"lithium-plate", "scrap-lithium-recycling"})
	technology.prerequisites = {"planet-discovery-fulgora"}
	helpers.set_science_unit(technology, 500, 60)
end

local function patch_cryogenic_plant()
	local technology = helpers.require_raw("technology", "cryogenic-plant")
	technology.prerequisites = {"lithium-processing", "ammonia-synthesis", "fluorine-processing"}
end

local function hide_removed_progression()
	local removed_recipes =
	{
		"ammoniacal-solution-separation",
		"solid-fuel-from-ammonia",
		"ammonia-rocket-fuel",
		"ice-platform",
		"lithium"
	}

	for _, recipe_name in pairs(removed_recipes) do
		helpers.remove_technology_effects_for_recipe(recipe_name)
		helpers.hide_recipe(recipe_name)
	end

	helpers.hide_item("ice-platform")
	helpers.set_default_import_location("ice-platform", nil)

	helpers.hide_prototype("fluid", "ammoniacal-solution")
	helpers.hide_prototype("fluid", "lithium-brine")
	helpers.hide_prototype("resource", "lithium-brine")
	helpers.hide_prototype("resource", "fluorine-vent")
end

local function patch_surface_conditions()
	local aquilo_locked_recipes =
	{
		"cryogenic-science-pack",
		"cryogenic-plant",
		"quantum-processor",
		"fusion-reactor",
		"fusion-generator"
	}

	for _, recipe_name in pairs(aquilo_locked_recipes) do
		helpers.remove_recipe_surface_conditions(recipe_name)
	end
end

local function patch_default_import_locations()
	local fulgora_imports =
	{
		"cryogenic-science-pack",
		"promethium-science-pack",
		"railgun-turret",
		"lithium",
		"lithium-plate",
		"quantum-processor",
		"fusion-power-cell",
		"fusion-reactor",
		"fusion-generator",
		"cryogenic-plant",
		"fluoroketone-cold-barrel",
		"fluoroketone-hot-barrel"
	}

	for _, item_name in pairs(fulgora_imports) do
		helpers.set_default_import_location(item_name, "fulgora")
	end

	helpers.set_default_import_location("foundation", "vulcanus")
end

local function patch_visible_fluid_sorting()
	helpers.require_raw("fluid", "ammonia").order = "b[new-fluid]-m[no-aquilo]-a[ammonia]"
	helpers.require_raw("fluid", "fluorine").order = "b[new-fluid]-m[no-aquilo]-b[fluorine]"
	helpers.require_raw("fluid", "fluoroketone-hot").order = "b[new-fluid]-m[no-aquilo]-c[fluoroketone-hot]"
	helpers.require_raw("fluid", "fluoroketone-cold").order = "b[new-fluid]-m[no-aquilo]-d[fluoroketone-cold]"
end

local function patch_public_subgroups()
	helpers.set_subgroup("item", "lithium", "no-aquilo-cryogenics", "a[lithium]-a[lithium]")
	helpers.set_subgroup("item", "lithium-plate", "no-aquilo-cryogenics", "a[lithium]-b[lithium-plate]")
	helpers.set_subgroup("item", "quantum-processor", "no-aquilo-cryogenics", "b[quantum]-a[quantum-processor]")
	helpers.set_subgroup("item", "fusion-power-cell", "no-aquilo-cryogenics", "c[fusion]-a[fusion-power-cell]")

	helpers.set_subgroup("recipe", "lithium-plate", "no-aquilo-cryogenics", "a[lithium]-b[lithium-plate]")
	helpers.set_subgroup("recipe", "fluoroketone", "no-aquilo-cryogenics", "b[fluoroketone]-a[fluoroketone]")
	helpers.set_subgroup("recipe", "fluoroketone-cooling", "no-aquilo-cryogenics", "b[fluoroketone]-b[fluoroketone-cooling]")
	helpers.set_subgroup("recipe", "quantum-processor", "no-aquilo-cryogenics", "b[quantum]-a[quantum-processor]")
	helpers.set_subgroup("recipe", "fusion-power-cell", "no-aquilo-cryogenics", "c[fusion]-a[fusion-power-cell]")
end

local function remove_aquilo_ui_hooks()
	helpers.require_raw("tips-and-tricks-item", "aquilo-briefing")
	helpers.require_raw("tips-and-tricks-item", "heating-mechanics")
	helpers.require_raw("change-surface-achievement", "visit-aquilo")

	data.raw["tips-and-tricks-item"]["aquilo-briefing"] = nil
	data.raw["tips-and-tricks-item"]["heating-mechanics"] = nil
	data.raw["change-surface-achievement"]["visit-aquilo"] = nil

	local utility_constants = helpers.require_raw("utility-constants", "default")
	if utility_constants.main_menu_simulations then
		utility_constants.main_menu_simulations.aquilo_send_help = nil
		utility_constants.main_menu_simulations.aquilo_starter = nil
	end
end

remove_aquilo_space_unlocks()
patch_space_connections()
patch_lithium_processing()
patch_cryogenic_plant()
hide_removed_progression()
patch_surface_conditions()
patch_default_import_locations()
patch_visible_fluid_sorting()
patch_public_subgroups()
remove_aquilo_ui_hooks()

helpers.require_raw("technology", "planet-discovery-aquilo")
data.raw.technology["planet-discovery-aquilo"] = nil
