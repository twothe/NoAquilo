local helpers = require("prototypes.helpers")

local scrap_lithium_recycling = table.deepcopy(helpers.require_raw("recipe", "scrap-recycling"))
scrap_lithium_recycling.name = "scrap-lithium-recycling"
scrap_lithium_recycling.localised_name = {"recipe-name.scrap-lithium-recycling"}
scrap_lithium_recycling.localised_description = {"recipe-description.scrap-lithium-recycling"}
scrap_lithium_recycling.icons =
{
	{
		icon = "__quality__/graphics/icons/recycling.png",
		icon_size = 64
	},
	{
		icon = "__space-age__/graphics/icons/scrap.png",
		icon_size = 64,
		scale = 0.35,
		shift = {-8, 8}
	},
	{
		icon = "__space-age__/graphics/icons/lithium.png",
		icon_size = 64,
		scale = 0.30,
		shift = {9, -8}
	},
	{
		icon = "__quality__/graphics/icons/recycling-top.png",
		icon_size = 64
	}
}
scrap_lithium_recycling.order = "a[trash]-b[lithium-recycling]"
scrap_lithium_recycling.enabled = false
table.insert(scrap_lithium_recycling.results, {type = "item", name = "lithium", amount = 1, probability = 0.01, show_details_in_recipe_tooltip = false})

data:extend(
{
	{
		type = "recipe",
		name = "ammonia-synthesis",
		localised_name = {"recipe-name.ammonia-synthesis"},
		localised_description = {"recipe-description.ammonia-synthesis"},
		icon = "__space-age__/graphics/icons/fluid/ammonia.png",
		icon_size = 64,
		category = "chemistry-or-cryogenics",
		subgroup = "agriculture-processes",
		order = "c[no-aquilo]-a[ammonia-synthesis]",
		auto_recycle = false,
		enabled = false,
		energy_required = 2,
		ingredients =
		{
			{type = "item", name = "spoilage", amount = 2},
			{type = "item", name = "iron-ore", amount = 2},
			{type = "fluid", name = "steam", amount = 100}
		},
		results = {{type = "fluid", name = "ammonia", amount = 50}},
		allow_productivity = true,
		crafting_machine_tint =
		{
			primary = {r = 0.50, g = 0.78, b = 0.64, a = 1.0},
			secondary = {r = 0.74, g = 0.83, b = 0.50, a = 1.0},
			tertiary = {r = 0.30, g = 0.44, b = 0.33, a = 1.0},
			quaternary = {r = 0.82, g = 0.94, b = 0.74, a = 1.0}
		}
	},
	{
		type = "recipe",
		name = "fluorine-extraction",
		localised_name = {"recipe-name.fluorine-extraction"},
		localised_description = {"recipe-description.fluorine-extraction"},
		icons =
		{
			{
				icon = "__space-age__/graphics/icons/fluid/fluorine.png",
				icon_size = 64
			},
			{
				icon = "__space-age__/graphics/icons/calcite.png",
				icon_size = 64,
				scale = 0.32,
				shift = {-9, 9},
				tint = {r = 0.36, g = 0.86, b = 0.20, a = 1.0}
			}
		},
		category = "chemistry-or-cryogenics",
		subgroup = "vulcanus-processes",
		order = "a[melting]-c[fluorine-extraction]",
		auto_recycle = false,
		enabled = false,
		energy_required = 4,
		ingredients =
		{
			{type = "item", name = "fluorite", amount = 10},
			{type = "fluid", name = "sulfuric-acid", amount = 100}
		},
		results = {{type = "fluid", name = "fluorine", amount = 100}},
		allow_productivity = true,
		crafting_machine_tint =
		{
			primary = {r = 0.34, g = 0.87, b = 0.29, a = 1.0},
			secondary = {r = 0.65, g = 0.84, b = 0.28, a = 1.0},
			tertiary = {r = 0.21, g = 0.31, b = 0.16, a = 1.0},
			quaternary = {r = 0.74, g = 1.0, b = 0.46, a = 1.0}
		}
	},
	scrap_lithium_recycling,
	{
		type = "recipe",
		name = "lithium-recovery",
		localised_name = {"recipe-name.lithium-recovery"},
		localised_description = {"recipe-description.lithium-recovery"},
		icons =
		{
			{
				icon = "__space-age__/graphics/icons/lithium.png",
				icon_size = 64
			},
			{
				icon = "__space-age__/graphics/icons/scrap.png",
				icon_size = 64,
				scale = 0.32,
				shift = {-9, 9}
			}
		},
		category = "chemistry-or-cryogenics",
		subgroup = "fulgora-processes",
		order = "a[trash]-c[lithium-recovery]",
		auto_recycle = false,
		enabled = false,
		energy_required = 10,
		ingredients =
		{
			{type = "item", name = "scrap", amount = 50},
			{type = "fluid", name = "petroleum-gas", amount = 50}
		},
		results = {{type = "item", name = "lithium", amount = 10}},
		allow_productivity = true,
		crafting_machine_tint =
		{
			primary = {r = 0.45, g = 0.84, b = 0.56, a = 1.0},
			secondary = {r = 0.44, g = 0.49, b = 0.62, a = 1.0},
			tertiary = {r = 0.30, g = 0.33, b = 0.34, a = 1.0},
			quaternary = {r = 0.80, g = 1.0, b = 0.87, a = 1.0}
		}
	}
})
