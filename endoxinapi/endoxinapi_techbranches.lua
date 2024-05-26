local AddComponentPostInit = AddComponentPostInit

GLOBAL.setfenv(1, GLOBAL)

local Builder = require("components/builder")
local RecipePopup = require("widgets/recipepopup")

--Overrides the KnowsRecipe check to check all fields of the form *_bonus. This lets it understand more than just the original three tech trees.
Builder.KnowsRecipe = function(self, recname)
	local recipe = GetRecipe(recname)
	if not recipe then return false end

	for k,v in pairs(recipe.level) do
		if self[string.lower(k).."_bonus"] < v then
			return self.freebuildmode or table.contains(self.recipes, recname)
		end
	end
	return true
end

--Returns the appropriate hint text for the recipe's tech tree and level, found in STRINGS.UI.PROTOTYPER_HINTS[TECHTYPE_NUM]. eg - SCIENCE_2
local function GetHintTextForRecipe(recipe)
	local neededTechs = {}
	for k,v in pairs(recipe.level) do
		if GetPlayer().components.builder.accessible_tech_trees[k] < v then
			table.insert(neededTechs, k)
		end
	end
	table.sort(neededTechs, function(a, b) return recipe.level[a] < recipe.level[b] end)
	local hint = STRINGS.UI.PROTOTYPER_HINTS[neededTechs[1].."_"..recipe.level[neededTechs[1]]]
	if hint then
		return hint
	else
		return STRINGS.UI.CRAFTING.CANTRESEARCH
	end
end

STRINGS.UI.PROTOTYPER_HINTS = {
	SCIENCE_1 = STRINGS.UI.CRAFTING.NEEDSCIENCEMACHINE,
	SCIENCE_2 = STRINGS.UI.CRAFTING.NEEDALCHEMYENGINE,
	MAGIC_2 = STRINGS.UI.CRAFTING.NEEDPRESTIHATITATOR,
	MAGIC_3 = STRINGS.UI.CRAFTING.NEEDSHADOWMANIPULATOR,
	ANCIENT_4 = STRINGS.UI.CRAFTING.NEEDSANCIENT_FOUR
}

--Overrides the hint text to be chosen by our function.
local oldFunction = RecipePopup.Refresh
RecipePopup.Refresh = function(self)
	oldFunction(self)
	if self and self.owner then
		local knows = self.owner.components.builder:KnowsRecipe(self.recipe.name)
		local tech_level = self.owner.components.builder.accessible_tech_trees
		local should_hint = not knows and ShouldHintRecipe(self.recipe.level, tech_level) and not CanPrototypeRecipe(self.recipe.level, tech_level)

		if should_hint then
			local str = GetHintTextForRecipe(self.recipe) or "Text not found."
			self.teaser:SetString(str)
		end
	end
end

--Adds registries for the specified new tech tree, at each level up to the specified maximum.
function AddTechBranch(name, maxlevel)
	for _,v in pairs(TECH) do
		v[name] = v[name] or 0
	end

	for _,v in pairs(TUNING.PROTOTYPER_TREES) do
		v[name] = v[name] or 0
	end

	for i=1,(maxlevel or 1) do
		local tech = deepcopy(TECH.NONE)
		tech[name] = i
		TECH[name.."_"..i] = tech
	end

	local oldFunction = Builder.EvaluateTechTrees
	Builder.EvaluateTechTrees = function(self)
		local had_prototyper = self.current_prototyper ~= nil
		oldFunction(self)
		if had_prototyper and not self.current_prototyper then
			self.accessible_tech_trees[name] = 0
			self.inst:PushEvent("techtreechange", {level = self.accessible_tech_trees})
		end
	end

	AddComponentPostInit("builder", function(self)
		self[string.lower(name).."_bonus"] = 0
	end)
end