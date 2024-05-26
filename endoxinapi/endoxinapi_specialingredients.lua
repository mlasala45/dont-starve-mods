GLOBAL.require("recipe")

Assets = Assets or {}
table.insert(Assets,Asset("ATLAS","images/si/health.xml"))
table.insert(Assets,Asset("IMAGE","images/si/health.tex"))
table.insert(Assets,Asset("ATLAS","images/si/hunger.xml"))
table.insert(Assets,Asset("IMAGE","images/si/hunger.tex"))
table.insert(Assets,Asset("ATLAS","images/si/sanity.xml"))
table.insert(Assets,Asset("IMAGE","images/si/sanity.tex"))

GLOBAL.SPECIALINGREDIENTS = {}

--Use this to define a special ingredient
function GLOBAL.DefineSpecialIngredient(name, amtfn, usefn)
	GLOBAL.SPECIALINGREDIENTS[string.upper(name)] = {
		amtfn = amtfn,
		usefn = usefn
	}
end

--Use this to use a defined special ingredient in a recipe
GLOBAL.SpecialIngredient = Class(function(self, type, amount, atlas)
	GLOBAL.assert(GLOBAL.SPECIALINGREDIENTS[string.upper(type)],"Attempt to use undefined special ingredient \""..type.."\"!")
	self.ingtype = "SPECIAL"
	self.type = type
	self.amount = amount or 1
	self.atlas = atlas
		or GLOBAL.resolvefilepath("images/si/"..type..".xml")
	self.amtfn = GLOBAL.SPECIALINGREDIENTS[string.upper(type)].amtfn
	self.usefn = GLOBAL.SPECIALINGREDIENTS[string.upper(type)].usefn
end)

--Use this to use a defined special ingredient in a recipe
GLOBAL.VariableIngredient = Class(function(self, ingredients)
	self.ingtype = "VARIABLE"
	self.ingredients = ingredients
	for k,v in pairs(ingredients) do
		GLOBAL.assert(v.ingtype ~= "VARIABLE", "Attempt to set a Variable Ingredient as an option for a Variable Ingredient!")
	end
end)

GLOBAL.TUNING.VARIABLE_INGREDIENT_CYCLE_PERIOD = 1

--Health

local amtfn_health = function(inst)
	if inst.components.health then
		return inst.components.health.currenthealth
	else
		return 0
	end
end

local usefn_health = function(inst, amount)
	if inst.components.combat then
		inst.components.combat:GetAttacked(nil,amount)
	else
		inst.components.health:DoDelta(-amount)
	end
end

GLOBAL.DefineSpecialIngredient("health", amtfn_health, usefn_health)
GLOBAL.STRINGS.NAMES.HEALTH = "Health"

--Hunger

local amtfn_hunger = function(inst)
	if inst.components.hunger then
		return inst.components.hunger.current
	else
		return 0
	end
end

local usefn_hunger = function(inst, amount)
	inst.components.hunger:DoDelta(-amount)
end

GLOBAL.DefineSpecialIngredient("hunger", amtfn_hunger, usefn_hunger)
GLOBAL.STRINGS.NAMES.HUNGER = "Hunger"

--Sanity

local amtfn_sanity = function(inst)
	if inst.components.sanity then
		return inst.components.sanity.current
	else
		return 0
	end
end

local usefn_sanity = function(inst, amount)
	inst.components.sanity:DoDelta(-amount)
end

GLOBAL.DefineSpecialIngredient("sanity", amtfn_sanity, usefn_sanity)
GLOBAL.STRINGS.NAMES.SANITY = "Sanity"

AddClassPostConstruct("widgets/crafttabs",function(self)
	local health_recipes,hunger_recipes,sanity_recipes = false,false,false
	for result,recipe in pairs(GLOBAL.GetAllRecipes()) do
		for i,ingredient in ipairs(recipe.ingredients) do
			if ingredient.type == "health" then
				health_recipes = true
			end
			if ingredient.type == "hunger" then
				hunger_recipes = true
			end
			if ingredient.type == "sanity" then
				sanity_recipes = true
			end
		end
	end
	if health_recipes then
		self.inst:ListenForEvent("healthdelta",function(inst)
			self:UpdateRecipes()
		end,self.owner)
	end
	if hunger_recipes then
		self.inst:ListenForEvent("hungerdelta",function(inst)
			self:UpdateRecipes()
		end,self.owner)
	end
	if sanity_recipes then
		self.inst:ListenForEvent("sanitydelta",function(inst)
			self:UpdateRecipes()
		end,self.owner)
	end
end)

AddGlobalClassPostConstruct("recipe", "Ingredient", function(self, type, amount, atlas)
	self.ingtype = "GENERIC"
	self.amount = amount or 1
end)

for k,v in pairs(GLOBAL.GetAllRecipes()) do
	for ik,iv in pairs(v.ingredients) do
		iv.ingtype = "GENERIC"
	end
end