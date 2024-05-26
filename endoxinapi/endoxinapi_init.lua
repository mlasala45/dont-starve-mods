local load = modimport

GLOBAL.setfenv(1,GLOBAL)

global("EndoxinAPI")
EndoxinAPI = {
	LoadedModules = {},

	LoadModule = function(self, module)
		if self.LoadedModules[module] then
			return
		end
		local name = self.ModuleNames[module]
		if name then
			self:Log("Loading module: "..name)
		else
			self:Log("Loading unknown module: "..module)
		end
		load("endoxinapi_"..module..".lua")
		self.LoadedModules[module] = true
	end,

	RequireModule = function(self, module)
		if not self.LoadedModules[module] then
			self:LoadModule(module)
		end
	end,

	Log = function(self, msg)
		print("\n[EndoxinAPI] "..tostring(msg))
	end,

	ModuleNames = {
		["specialingredients"] = "Special Ingredients",
		["duplicaterecipes"] = "Duplicate Recipes",
		["recipetabs"] = "Recipe Tabs",
		["misc"] = "Miscellaneous Functionality",
		["recipetabs"] = "Recipe Tabs",
		["techbranches"] = "Tech Branches",
		["worlds"] = "Worlds"
	}
}