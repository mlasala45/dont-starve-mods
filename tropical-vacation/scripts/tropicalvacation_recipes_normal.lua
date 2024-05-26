local shadowportal_tab = RECIPETABS.MAGIC
local shadowportal_level = TECH.NONE
local shadowportal_nounlock = false
if CRAFTINGLEVEL == 1 then
	shadowportal_level = TECH.MAGIC_TWO
elseif CRAFTINGLEVEL == 2 then
	shadowportal_level = TECH.MAGIC_THREE
elseif CRAFTINGLEVEL == 3 then
	shadowportal_tab = RECIPETABS.ANCIENT
	shadowportal_level = TECH.ANCIENT_TWO
	shadowportal_nounlock = true
elseif CRAFTINGLEVEL == 4 then
	shadowportal_tab = RECIPETABS.ANCIENT
	shadowportal_level = TECH.ANCIENT_FOUR
	shadowportal_nounlock = true
end

local shadowportal_recipe = Recipe("shadowportal", {Ingredient("livinglog", 4), Ingredient("nightmarefuel", 4), Ingredient("purplegem", 1)}, shadowportal_tab, shadowportal_level, "shadowportal_placer", nil, shadowportal_nounlock)
shadowportal_recipe.atlas = "images/shadowportal.xml"
shadowportal_recipe.sortkey = 1