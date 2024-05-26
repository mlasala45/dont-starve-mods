GLOBAL.EndoxinAPI:RequireModule("misc")

GLOBAL.require("recipe")

local recipe_sets
if GLOBAL.IsDLCEnabled(GLOBAL.CAPY_DLC) then 
	recipe_sets = {
		GLOBAL.Common_Recipes,
		GLOBAL.Shipwrecked_Recipes,
		GLOBAL.RoG_Recipes,
		GLOBAL.Vanilla_Recipes
	}
else
	recipe_sets = {
		GLOBAL.Recipes
	}
end
local index = function(t,k)
	return t[k]
end

local exists = function(rec)
	for _,recipe_set in ipairs(recipe_sets) do
		if recipe_set[rec] then
			return true
		end
	end
	return false
end

local newindex = function(t,k,v)
	while exists(k) do
		k = "dummy_"..k
		GLOBAL.STRINGS.NAMES[string.upper(k)] = GLOBAL.STRINGS.NAMES[string.upper(k:sub(7))]
		GLOBAL.STRINGS.RECIPE_DESC[string.upper(k)] = GLOBAL.STRINGS.RECIPE_DESC[string.upper(k:sub(7))]
	end
	v.name = k
	t[k] = v
end

for _,recipe_set in ipairs(recipe_sets) do
	GLOBAL.SetProxy(recipe_set, index, newindex)

	--This code is run after vanilla recipes are set, so they need to be run through the new functionality
	for k,v in pairs(recipe_set) do
		recipe_set[k] = nil
		recipe_set[k] = v
	end
end