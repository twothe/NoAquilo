local helpers = {}

helpers.standard_science_pack_unit =
{
	{"automation-science-pack", 1},
	{"logistic-science-pack", 1},
	{"chemical-science-pack", 1},
	{"production-science-pack", 1},
	{"utility-science-pack", 1},
	{"space-science-pack", 1},
	{"metallurgic-science-pack", 1},
	{"agricultural-science-pack", 1},
	{"electromagnetic-science-pack", 1}
}

local item_prototype_types =
{
	"item",
	"tool",
	"ammo",
	"gun",
	"armor",
	"capsule",
	"module",
	"rail-planner",
	"repair-tool",
	"item-with-entity-data",
	"item-with-inventory",
	"item-with-label",
	"item-with-tags",
	"selection-tool",
	"blueprint",
	"blueprint-book",
	"copy-paste-tool",
	"deconstruction-item",
	"upgrade-item",
	"spidertron-remote",
	"space-platform-starter-pack"
}

function helpers.require_raw(prototype_type, name)
	local prototypes = data.raw[prototype_type]
	if not prototypes or not prototypes[name] then
		error("No Aquilo expected prototype '" .. prototype_type .. "." .. name .. "' to exist.")
	end
	return prototypes[name]
end

function helpers.find_item(name)
	for _, prototype_type in pairs(item_prototype_types) do
		local prototypes = data.raw[prototype_type]
		if prototypes and prototypes[name] then
			return prototypes[name], prototype_type
		end
	end
	return nil, nil
end

function helpers.require_item(name)
	local item, prototype_type = helpers.find_item(name)
	if not item then
		error("No Aquilo expected item-like prototype '" .. name .. "' to exist.")
	end
	return item, prototype_type
end

function helpers.set_default_import_location(item_name, location)
	local item = helpers.require_item(item_name)
	item.default_import_location = location
end

function helpers.hide_recipe(recipe_name)
	local recipe = helpers.require_raw("recipe", recipe_name)
	recipe.enabled = false
	recipe.hidden = true
	recipe.hide_from_player_crafting = true
	return recipe
end

function helpers.hide_item(item_name)
	local item = helpers.require_item(item_name)
	item.hidden = true
	return item
end

function helpers.hide_prototype(prototype_type, name)
	local prototype = helpers.require_raw(prototype_type, name)
	prototype.hidden = true
	prototype.hidden_in_factoriopedia = true
	return prototype
end

function helpers.remove_technology_effects_for_recipe(recipe_name)
	for _, technology in pairs(data.raw.technology or {}) do
		local effects = technology.effects
		if effects then
			for index = #effects, 1, -1 do
				local effect = effects[index]
				if effect.recipe == recipe_name then
					table.remove(effects, index)
				end
			end
		end
	end
end

function helpers.assert_recipe_has_no_unlock(recipe_name)
	for technology_name, technology in pairs(data.raw.technology or {}) do
		for _, effect in pairs(technology.effects or {}) do
			if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
				error("No Aquilo expected recipe '" .. recipe_name .. "' to have no unlock, but it is unlocked by technology '" .. technology_name .. "'.")
			end
		end
	end
end

function helpers.add_recipe_unlock(technology, recipe_name)
	technology.effects = technology.effects or {}
	for _, effect in pairs(technology.effects) do
		if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
			return
		end
	end
	table.insert(technology.effects, {type = "unlock-recipe", recipe = recipe_name})
end

function helpers.set_recipe_unlocks(technology, recipe_names)
	technology.effects = {}
	for _, recipe_name in pairs(recipe_names) do
		helpers.add_recipe_unlock(technology, recipe_name)
	end
end

function helpers.set_science_unit(technology, count, time)
	technology.research_trigger = nil
	technology.unit =
	{
		count = count,
		ingredients = table.deepcopy(helpers.standard_science_pack_unit),
		time = time
	}
end

function helpers.remove_recipe_surface_conditions(recipe_name)
	local recipe = helpers.require_raw("recipe", recipe_name)
	recipe.surface_conditions = nil
	return recipe
end

function helpers.set_subgroup(prototype_type, name, subgroup, order)
	local prototype = helpers.require_raw(prototype_type, name)
	prototype.subgroup = subgroup
	if order then
		prototype.order = order
	end
	return prototype
end

function helpers.contains(values, value)
	for _, current in pairs(values or {}) do
		if current == value then
			return true
		end
	end
	return false
end

return helpers
