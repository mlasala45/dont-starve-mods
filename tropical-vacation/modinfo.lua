name = "Tropical Vacation"
description = "Take a relaxing vacation to the tropics, using this convienient, not at all sinister shadow portal!"
author = "Arkathorn"
version = "2.5"

forumthread = "/files/file/1358-tropical-vacation/"

api_version = 6

dst_compatible = false
dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

configuration_options = {	
	{
		name = "ALLOWADVENTUREPORTALS",
		label = "Allow in Adventure Mode?",
		options = {
			{description = "No", data = false},
			{description = "Yes", data = true}
		},
		default = false
	},
	{
		name = "CRAFTINGLEVEL",
		label = "Portal Crafting Level",
		options = {
			{description = "No Machine", data = 0},
			{description = "Prestihatitator", data = 1},
			{description = "Shadow Maniulator", data = 2},
			{description = "Broken Ancient Altar", data = 3},
			{description = "Ancient Altar", data = 4}
		},
		default = 0
	}
}