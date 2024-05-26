name = "Meteors!"
description = "Adds the meteors from DST to the base game. NOTE: Almost all content was taken from the game, not made by me!"
author = "Arkathorn"
version = "1.4"

forumthread = "/files/file/1327-meteors/"

api_version = 6

dst_compatible = false
dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true

icon_atlas = "images/modicon.xml"
icon = "modicon.tex"

configuration_options = {	
	{
		name = "METEORSHOWERS",
		label = "Meteor Frequency",
		options = {
			{description = "None", data = -2},
			{description = "Less", data = -1},
			{description = "Default", data = 0},
			{description = "More", data = 1},
			{description = "Lots", data = 2}
		},
		default = 0,	
	}	
}