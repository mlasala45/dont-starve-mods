NP = { 
	name=STRINGS.MISC.NEW_PRESET,
	id=nil,
	overrides={
			{"start_setpeice", 	"DefaultStart"},		
			{"start_node",		"Clearing"}
	},
	tasks = {
			"Nothing"
	}
}

MYST_WORLDGEN = {
	FOREST = function(id,name)
		return {
			name=name,
			id="AGE_"..id,
			overrides={
				{"start_setpeice", 	"DefaultStart"},		
				{"start_node",		"Clearing"}
			},
			tasks = {
					"Make a pick",
					"Dig that rock",
					"Great Plains",
					"Squeltch",
					"Beeeees!",
					"Speak to the king",
					"Forest hunters"
			},
			numoptionaltasks = 4,
			optionaltasks = {
					"Befriend the pigs",
					"For a nice walk",
					"Kill the spiders",
					"Killer bees!",
					"Make a Beehat",
					"The hunters",
					"Magic meadow",
					"Frogs and bugs"
			},
			set_pieces = {
				["ResurrectionStone"] = { count=2, tasks={"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters" } },
				["WormholeGrass"] = { count=8, tasks={"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Befriend the pigs", "For a nice walk", "Kill the spiders", "Killer bees!", "Make a Beehat", "The hunters", "Magic meadow", "Frogs and bugs"} },
			},
			ordered_story_setpieces = {
				"TeleportatoRingLayout",
				"TeleportatoBoxLayout",
				"TeleportatoCrankLayout",
				"TeleportatoPotatoLayout",
				"AdventurePortalLayout",
				"TeleportatoBaseLayout"
			},
			required_prefabs = {
				"teleportato_ring",  "teleportato_box",  "teleportato_crank", "teleportato_potato", "teleportato_base", "chester_eyebone", "adventure_portal", "pigking"
			}
		}
	end,

	CAVES_1 = function(id,name)
		return {
			name=name,
			id="AGE_"..id,
			overrides={
				{"world_size", 		"tiny"},
				{"day", 			"onlynight"}, 
				{"waves", 			"off"},
				{"location",		"cave"},
				{"boons", 			"never"},
				{"poi", 			"never"},
				{"traps", 			"never"},
				{"protected", 		"never"},
				{"start_setpeice", 	"RuinsStart"},
				{"start_node",		"BGWilds"}
			},
			tasks={
				"RuinsStart",
				"TheLabyrinth",
				"Residential",
				"Military",
				"Sacred"
			},
			numoptionaltasks = math.random(1,2),
			optionaltasks = {
				"MoreAltars",
				"SacredDanger",
				"FailedCamp",
				"Residential2",
				"Residential3",
				"Military2",
				"Sacred2"
			}
		}
	end,

	CAVES_2 = function(id,name)
		return {
			name=name,
			id="AGE_"..id,
			overrides={
				{"world_size", 		"tiny"},
				{"day", 			"onlynight"}, 
				{"waves", 			"off"},
				{"location",		"cave"},
				{"boons", 			"never"},
				{"poi", 			"never"},
				{"traps", 			"never"},
				{"protected", 		"never"},
				{"start_setpeice", 	"RuinsStart"},
				{"start_node",		"BGWilds"}
			},
			tasks={
				"RuinsStart",
				"TheLabyrinth",
				"Residential",
				"Military",
				"Sacred"
			},
			numoptionaltasks = math.random(1,2),
			optionaltasks = {
				"MoreAltars",
				"SacredDanger",
				"FailedCamp",
				"Residential2",
				"Residential3",
				"Military2",
				"Sacred2"
			}
		}
	end,
}