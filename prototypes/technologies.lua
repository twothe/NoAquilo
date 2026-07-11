-- Defines the replacement research gates for non-Aquilo resource production.
local helpers = require("prototypes.helpers")

local function standard_unit(count)
	return
	{
		count = count,
		ingredients = table.deepcopy(helpers.standard_science_pack_unit),
		time = 60
	}
end

data:extend(
{
	{
		type = "technology",
		name = "ammonia-synthesis",
		icon = "__space-age__/graphics/icons/fluid/ammonia.png",
		icon_size = 64,
		effects =
		{
			{type = "unlock-recipe", recipe = "ammonia-synthesis"}
		},
		prerequisites = {"metallurgic-science-pack", "agricultural-science-pack", "electromagnetic-science-pack"},
		unit = standard_unit(500)
	},
	{
		type = "technology",
		name = "fluorine-processing",
		icons =
		{
			{
				icon = "__space-age__/graphics/icons/fluid/fluorine.png",
				icon_size = 64
			},
			{
				icon = "__space-age__/graphics/icons/calcite.png",
				icon_size = 64,
				scale = 0.30,
				shift = {-10, 10},
				tint = {r = 0.36, g = 0.86, b = 0.20, a = 1.0}
			}
		},
		effects =
		{
			{type = "unlock-recipe", recipe = "fluorine-extraction"}
		},
		prerequisites = {"metallurgic-science-pack", "agricultural-science-pack", "electromagnetic-science-pack"},
		unit = standard_unit(500)
	},
	{
		type = "technology",
		name = "lithium-recovery",
		icons =
		{
			{
				icon = "__space-age__/graphics/technology/lithium-processing.png",
				icon_size = 256
			},
			{
				icon = "__space-age__/graphics/icons/scrap.png",
				icon_size = 64,
				scale = 0.32,
				shift = {-34, 34}
			}
		},
		effects =
		{
			{type = "unlock-recipe", recipe = "lithium-recovery"}
		},
		prerequisites = {"lithium-processing", "ammonia-synthesis", "fluorine-processing"},
		unit = standard_unit(2000)
	}
})
