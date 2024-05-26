local DEBUG = false

GLOBAL.require("map/levels")

GLOBAL.DIMENSION_IDS = {}

--Creates a dimension with the specified worldgen data, and adds it's name to the registry.
function GLOBAL.RegisterDimension(dimname, data)
	GLOBAL.assert(dimname, "Attempted to register a dimension with a nil name")
	GLOBAL.assert(dimname ~= "", "Attempted to register a dimension with an empty name")
	print("Registering dimension: "..dimname)
	AddLevel(GLOBAL.LEVELTYPE.CUSTOM, data)
	GLOBAL.global("DIMENSION_IDS")
	GLOBAL.DIMENSION_IDS = GLOBAL.DIMENSION_IDS or {}
	local length = 0
	for k,v in pairs(GLOBAL.DIMENSION_IDS) do
		length = length + 1
	end
	GLOBAL.DIMENSION_IDS[dimname] = length + 1
	print("Dimension ID for "..dimname.." is "..GLOBAL.DIMENSION_IDS[dimname])
end

--Gets the ID associated with a dimension name (used as an index in the custom worldgen table).
function GetDimensionIDFromName(name)
	GLOBAL.assert(GLOBAL.DIMENSION_IDS, "Dimension registry was missing on lookup")
	return GLOBAL.DIMENSION_IDS[name]
end

local standard_dims = {
	"forest",
	"cave",
	"adventure",
	"tropics",
	"volcano",
	"test"
}

function IsDimensionStandard(name)
	if name == "survival" then
		name = "forest"
	elseif name == "shipwrecked" then
		name = "tropics"
	end
	for i,v in ipairs(standard_dims) do
		if v == name then
			return true
		end
	end
	return false
end

--This code overrides json.decode, so we can get at the WorldGen parameters and code. Though it isn't watertight, it should be fine.
local patched = false
local json = GLOBAL.require("json")
local decode = json.decode
json.decode = function(s, startPos)
	if GLOBAL.rawget(GLOBAL, "GenerateNew") and not patched then
		local fn = GLOBAL.GenerateNew
		GLOBAL.GenerateNew = function(...)
			local strdata = fn(...)
			if strdata then
				local success, savedata = GLOBAL.RunInSandbox(strdata)
				print("savedata.map.prefab",savedata.map.prefab)
				print("savedata.map.topology.level_type",savedata.map.topology.level_type)
				print("savedata.map.topology.location",savedata.map.topology.location)
				if savedata.map.prefab == "forest" and savedata.map.topology.level_type ~= "survival" and savedata.map.topology.level_type ~= "adventure" then
					print("HEY, WHERE'D YOU GET THAT BODY FROM?")
					savedata.map.prefab = savedata.map.topology.level_type
					print("I GOT IT FROM MY DADDY!")
					print(savedata.map.prefab)
					strdata = GLOBAL.DataDumper(savedata, nil, GLOBAL.PLATFORM == "NACL")
				end
			end
			return strdata
		end
		patched = true
	end
	local a,b = decode(s, startPos)
	if type(a) == type({}) then
		if DEBUG then
			print("JSON Decode returned a table.")
			print(a)
			if a.world_gen_choices and a.level_type then
				print("It's the Worldgen options!")
			end
			print("Displaying:")
			for k,v in pairs(a) do
				print(k,v)
				if type(v) == type({}) then
					print("{")
					for kk,vv in pairs(v) do
						print(kk,vv)
						if type(vv) == type({}) then
							print("{")
							for kkk,vvv in pairs(vv) do
								print(kkk,vvv)
							end
							print("}")
						end
					end
					print("}")
				end
			end
		end
		if a.world_gen_choices and a.level_type and not IsDimensionStandard(a.level_type) then
			if GetDimensionIDFromName(a.level_type) then --This should never happen
				a.world_gen_choices.level_id = GetDimensionIDFromName(a.level_type)
			else
				local mt = GLOBAL.getmetatable(a.world_gen_choices)
				if not mt then
					mt = {}
					GLOBAL.setmetatable(a.world_gen_choices, mt)
				end
				a.world_gen_choices.level_type = a.level_type
				local patcher = function(t,k)
					if k == "level_id" then
						if GetDimensionIDFromName(t.level_type) then
							t.level_id = GetDimensionIDFromName(t.level_type)
							GLOBAL.setmetatable(t, nil)
							return t.level_id
						end
					end
				end
				mt.__index = function(t,k)
					return patcher(t,k)
				end
			end
		end
	end
	return a, b
end