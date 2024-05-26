local Assets = {
	Asset("ATLAS", "images/wall_moonrock_item.xml"),
	Asset("IMAGE", "wall_moonrock_item"),

	Asset("ATLAS", "images/moonrocknugget.xml"),
	Asset("IMAGE", "images/moonrocknugget.tex")
}

local recipe_moonrock_wall = Recipe("wall_moonrock_item", {Ingredient("moonrocknugget", 12, "images/moonrocknugget.xml")}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, nil, nil, nil, 4)
recipe_moonrock_wall.atlas = resolvefilepath("images/wall_moonrock_item.xml")
recipe_moonrock_wall.image = "wall_moonrock_item.tex"