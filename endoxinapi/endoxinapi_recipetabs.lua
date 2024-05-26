--Adds the specified tab. Access it at GLOBAL.RECIPETABS[str], or from the return value of the function.
function GLOBAL.AddRecipeTab(str, sort, atlas, icon)
	str = str or ""
	str = string.upper(str)
	GLOBAL.RECIPETABS[str] =
	{
		["str"] = str,
		["sort"] = sort,
		["icon_atlas"] = atlas,
		["icon"] = icon
	}
	return GLOBAL.RECIPETABS[str]
end

--Only applies after recipes.lua is loaded, but vanilla recipes shouldn't have this issue anyway.
--This ensures that recipes with tabs that share 'str' values will not create duplicate tabs. The tab will have the attributes specified in it's first reference.
AddGlobalClassPostConstruct("recipe","Recipe", function(self)
	if self.tab and self.tab.str then
		self.tab.str = string.upper(self.tab.str)
		if GLOBAL.RECIPETABS[self.tab.str] then
			self.tab = GLOBAL.RECIPETABS[self.tab.str]
		else
			GLOBAL.RECIPETABS[self.tab.str] = self.tab
		end
	end
end)