local Layouts = GLOBAL.require("map/layouts").Layouts
local StaticLayout = GLOBAL.require("map/static_layout")

Layouts["DragonflyArena"] = StaticLayout.Get("map/static_layouts/dragonfly_arena",
	{
			start_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			layout_position = GLOBAL.LAYOUT_POSITION.CENTER
	})

AddLevelPreInit("SURVIVAL_DEFAULT", function(level)
	level.set_pieces["DragonflyArena"] = { count = 1, tasks = {"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Befriend the pigs", "For a nice walk", "Kill the spiders", "Killer bees!", "Make a Beehat", "The hunters", "Magic meadow", "Frogs and bugs"} }
end)