local helpers = require("prototypes.helpers")

local fluorite_tint = {r = 0.36, g = 0.86, b = 0.20, a = 1.0}
local fluorite_light_tint = {r = 0.25, g = 0.95, b = 0.18, a = 0.35}
local calcite_icon_root = "__space-age__/graphics/icons/"

local function fluorite_icon(filename)
	return
	{
		layers =
		{
			{
				filename = calcite_icon_root .. filename,
				size = 64,
				scale = 0.5,
				mipmap_count = 4,
				tint = fluorite_tint
			},
			{
				filename = calcite_icon_root .. filename,
				blend_mode = "additive",
				draw_as_light = true,
				size = 64,
				scale = 0.5,
				tint = fluorite_light_tint
			}
		}
	}
end

local fluorite_item = table.deepcopy(helpers.require_raw("item", "calcite"))
fluorite_item.name = "fluorite"
fluorite_item.localised_name = {"item-name.fluorite"}
fluorite_item.localised_description = {"item-description.fluorite"}
fluorite_item.icon = nil
fluorite_item.icons =
{
	{
		icon = "__space-age__/graphics/icons/calcite.png",
		icon_size = 64,
		tint = fluorite_tint
	}
}
fluorite_item.pictures =
{
	fluorite_icon("calcite.png"),
	fluorite_icon("calcite-1.png"),
	fluorite_icon("calcite-2.png"),
	fluorite_icon("calcite-3.png")
}
fluorite_item.subgroup = "vulcanus-processes"
fluorite_item.order = "a[melting]-b[fluorite]"
fluorite_item.stack_size = 50
fluorite_item.default_import_location = "vulcanus"
fluorite_item.weight = 2 * kg

local fluorite_resource = table.deepcopy(helpers.require_raw("resource", "calcite"))
fluorite_resource.name = "fluorite"
fluorite_resource.localised_name = {"entity-name.fluorite"}
fluorite_resource.icon = nil
fluorite_resource.icons =
{
	{
		icon = "__space-age__/graphics/icons/calcite.png",
		icon_size = 64,
		tint = fluorite_tint
	}
}
fluorite_resource.order = "b-c-f"
fluorite_resource.minable.result = "fluorite"
fluorite_resource.map_color = {r = 0.30, g = 0.78, b = 0.12, a = 1.0}
fluorite_resource.mining_visualisation_tint = {r = 0.46, g = 1.0, b = 0.24, a = 1.0}
fluorite_resource.factoriopedia_simulation = nil
fluorite_resource.autoplace =
{
	order = "b-d",
	probability_expression = "vulcanus_fluorite_probability",
	richness_expression = "vulcanus_fluorite_richness"
}

if fluorite_resource.stages and fluorite_resource.stages.sheet then
	fluorite_resource.stages.sheet.tint = fluorite_tint
end

data:extend(
{
	{
		type = "autoplace-control",
		name = "fluorite",
		localised_name = {"", "[entity=fluorite] ", {"entity-name.fluorite"}},
		richness = true,
		order = "b-c-a",
		category = "resource"
	},
	{
		type = "noise-expression",
		name = "vulcanus_fluorite_size",
		expression = "slider_rescale(control:fluorite:size, 2)"
	},
	{
		type = "noise-expression",
		name = "vulcanus_fluorite_region",
		expression = "max(0, min(1 - vulcanus_starting_circle, vulcanus_place_non_metal_spots(915, 8, 1, vulcanus_fluorite_size * min(1.2, vulcanus_ore_dist) * 18, control:fluorite:frequency, vulcanus_mountains_resource_favorability)))"
	},
	{
		type = "noise-expression",
		name = "vulcanus_fluorite_probability",
		expression = "(control:fluorite:size > 0) * (1000 * ((1 + vulcanus_fluorite_region) * random_penalty_between(0.9, 1, 1) - 1))"
	},
	{
		type = "noise-expression",
		name = "vulcanus_fluorite_richness",
		expression = "vulcanus_fluorite_region * random_penalty_between(0.9, 1, 1) * 16000 * vulcanus_starting_area_multiplier * control:fluorite:richness / vulcanus_fluorite_size"
	},
	fluorite_item,
	fluorite_resource
})

local vulcanus = helpers.require_raw("planet", "vulcanus")
vulcanus.map_gen_settings = vulcanus.map_gen_settings or {}
vulcanus.map_gen_settings.property_expression_names = vulcanus.map_gen_settings.property_expression_names or {}
vulcanus.map_gen_settings.autoplace_controls = vulcanus.map_gen_settings.autoplace_controls or {}
vulcanus.map_gen_settings.autoplace_settings = vulcanus.map_gen_settings.autoplace_settings or {}
vulcanus.map_gen_settings.autoplace_settings.entity = vulcanus.map_gen_settings.autoplace_settings.entity or {}
vulcanus.map_gen_settings.autoplace_settings.entity.settings = vulcanus.map_gen_settings.autoplace_settings.entity.settings or {}

vulcanus.map_gen_settings.property_expression_names["entity:fluorite:probability"] = "vulcanus_fluorite_probability"
vulcanus.map_gen_settings.property_expression_names["entity:fluorite:richness"] = "vulcanus_fluorite_richness"
vulcanus.map_gen_settings.autoplace_controls["fluorite"] = {}
vulcanus.map_gen_settings.autoplace_settings.entity.settings["fluorite"] = {}
