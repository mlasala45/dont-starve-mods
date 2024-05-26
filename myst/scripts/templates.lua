TEMPLATES = {
	WORLDBOOK = {
		name = {name=STRINGS.TEMPLATES.WORLDBOOK.NAME,type="string"},
		type = {name=STRINGS.TEMPLATES.WORLDBOOK.TYPE,type="choice",choice_set="world_types"},

		__NEW = {
			name=STRINGS.MISC.NEW_WORLDBOOK,
			type="forest"
		},

		__TITLE = function(data) return data.name end
	}
}

local function GetWorldTypesSet()
	local types = {
		{name="Forest World",data="forest"},
		{name="Cave World",data="cave"}	
	}
	if IsDLCEnabled(CAPY_DLC) then
		table.insert(types, {name="Tropical World",data="tropics"})
	end
	return types
end

function GetChoiceSet(set)
	local functions = {
		["world_types"]=GetWorldTypesSet
	}
	local fn = functions[set]
	if fn then
		return fn()
	else
		print("Set not found: ",set)
		return {}
	end
end