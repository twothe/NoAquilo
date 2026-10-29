-- Verifies engine-resolved map defaults and research unlocks in an isolated new game.
-- This test mod is never included in the release ZIP.
script.on_init(function()
	for _, name in pairs({"aquilo_crude_oil", "lithium_brine", "fluorine_vent"}) do
		assert(prototypes.autoplace_control[name].hidden, name .. " must be hidden from map generation")
	end

	local aquilo = game.planets.aquilo.create_surface()
	for _, name in pairs({"aquilo_crude_oil", "lithium_brine", "fluorine_vent"}) do
		local settings = aquilo.map_gen_settings.autoplace_controls[name]
		assert(settings.size == 0 and settings.richness == 0 and settings.frequency == 1,
			name .. " must default to disabled without invalid noise expressions")
	end

	for planet_name, resource_name in pairs({nauvis = "crude-oil", vulcanus = "fluorite", fulgora = "scrap"}) do
		local surface = game.planets[planet_name].create_surface()
		local settings = surface.map_gen_settings.autoplace_controls[resource_name]
		assert(settings.size > 0 and settings.richness > 0, resource_name .. " must remain enabled")
	end

	local force = game.forces.player
	assert(not force.technologies["planet-discovery-aquilo"], "Aquilo discovery must not exist")
	assert(not force.recipes["scrap-lithium-recycling"].enabled, "Lithium recycling must start locked")
	force.technologies["lithium-processing"].researched = true
	assert(force.recipes["scrap-lithium-recycling"].enabled, "Lithium processing must unlock late recycling")
	assert(force.recipes["lithium-plate"].enabled, "Lithium processing must unlock lithium plates")
	assert(not force.recipes.lithium.enabled, "The brine recipe must remain locked")
	log("NO_AQUILO_RUNTIME_CONTRACT_OK")
end)
