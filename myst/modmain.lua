--[[
-- Requires EndoxinAPI
--]]

GLOBAL.assert(GLOBAL.rawget(GLOBAL, "EndoxinAPI"), "This mod requires EndoxinAPI.")

local require = GLOBAL.require
require "myst_strings"
require "myst_tuning"
require "myst_constants"
require "myst_recipes"

require "templates"

local RecipeAssets = {
	Asset("ATLAS", "images/grinder.xml"),
	Asset("IMAGE", "images/grinder.tex"),

	Asset("ATLAS", "images/acorn_ground.xml"),
	Asset("IMAGE", "images/acorn_ground.tex"),

	Asset("ATLAS", "images/coconut_ground.xml"),
	Asset("IMAGE", "images/coconut_ground.tex"),

	Asset("ATLAS", "images/pinecone_ground.xml"),
	Asset("IMAGE", "images/pinecone_ground.tex"),

	Asset("ATLAS", "images/gumarabic_ground.xml"),
	Asset("IMAGE", "images/gumarabic_ground.tex"),

	Asset("ATLAS", "images/ink.xml"),
	Asset("IMAGE", "images/ink.tex"),
	
	Asset("ATLAS", "images/quill.xml"),
	Asset("IMAGE", "images/quill.tex"),

	Asset("ATLAS", "images/writingdesk.xml"),
	Asset("IMAGE", "images/writingdesk.tex"),

	Asset("ATLAS", "images/linkpanel.xml"),
	Asset("IMAGE", "images/linkpanel.tex"),

	Asset("ATLAS", "images/worldbook.xml"),
	Asset("IMAGE", "images/worldbook.tex"),

	Asset("ATLAS", "images/linkbook.xml"),
	Asset("IMAGE", "images/linkbook.tex")
}

local UIAssets = {
	Asset("ATLAS", "images/ui/arrows.xml"),
	Asset("IMAGE", "images/ui/arrows.tex")
}

Assets = {}

for k,v in pairs(RecipeAssets) do
	table.insert(Assets, v)
end

for k,v in pairs(UIAssets) do
	table.insert(Assets, v)
end

PrefabFiles = {
	"grounditems",
	"grinder",
	"gumarabic",
	"quill",
	"ink",
	"writingdesk",
	"linkpanel",
	"worldbook",
	"linkbook"
}

for i,v in ipairs({"acorn","coconut","pinecone"}) do
	AddPrefabPostInit(v, function(self)
		self:AddTag("grindable")
	end)
end

AddPrefabPostInit("cave_exit", function(self)
	if GLOBAL.AgeIndex:IsAge() then
		self:Remove()
	end
end)

AddPrefabPostInit("cave_entrance", function(self)
	if GLOBAL.AgeIndex:IsAge() then
		self:Remove()
	end
end)

AddComponentPostInit("maxwelltalker", function(self)
	if GLOBAL.AgeIndex:IsAge() then
		self.inst:DoTaskInTime(0,function()
			self:OnCancel()
			self.inst:Remove()
		end)
	end
end)

AddPrefabPostInitAny(function(self)
	if self:HasTag("tree") then
		self:ListenForEvent("workfinished", function()
			if math.random(0,5) == 0 then
				local item = GLOBAL.SpawnPrefab("gumarabic")
				item.Transform:SetPosition(self.Transform:GetWorldPosition())
				item.components.inventoryitem:OnDropped()
			end
		end)
	end
end)

AddPlayerPostInit(function(self)
	self:AddComponent("reader")
	self:AddComponent("mystfader")
	self:AddComponent("agewriter")

	self:DoTaskInTime(0,function(self)
		if GLOBAL.AgeIndex:IsAge() then
			local x,y,z = self.Transform:GetWorldPosition()
			GLOBAL.AgeIndex:SetLinkSpot(GLOBAL.AgeIndex:GetCurrentAge(), x, y, z)
		end
	end)
end)

AddStategraphState("wilson", GLOBAL.State({
	name = "still",
	tags = {"mod","busy"},
	onenter = function(inst)
		inst.components.locomotor:StopMoving()
		inst.components.playercontroller:Enable(false)
		inst.components.health:SetInvincible(true)
		GLOBAL.TheCamera:SetDistance(20)
		inst.HUD:Hide()
	end
}))

AddGlobalClassPostConstruct("saveindex", "SaveIndex", function(self)
	GLOBAL.global("SaveGameIndex")
	GLOBAL.SaveGameIndex = self
	local AgeIndex = require "ageindex"
	GLOBAL.global("AgeIndex")
	GLOBAL.AgeIndex = AgeIndex()

	local fn_deleteslot = self.DeleteSlot
	self.DeleteSlot = function(inst, slot, ...)
		fn_deleteslot(inst, slot, ...)
		GLOBAL.AgeIndex:DeleteSlot(slot)
	end

	local fn_save = self.Save
	self.Save = function(callback, indexname, isbackup)
		GLOBAL.AgeIndex:OnSave()
		fn_save(callback, indexname, isbackup)
	end

	if GLOBAL.IsDLCInstalled(GLOBAL.CAPY_DLC) then
		local fn_ismodeshipwrecked = self.IsModeShipwrecked
		self.IsModeShipwrecked = function(self, slot)
			return fn_ismodeshipwrecked(self,slot) or (self:GetCurrentMode(slot) and GLOBAL.AgeIndex:IsAge(slot) and GLOBAL.AgeIndex:GetAgeType(self:GetCurrentMode(slot)) == "tropics")
		end
	end
end)

AddClassPostConstruct("screens/loadgamescreen", function(self)
	local fn = self.MakeSaveTile
	self.MakeSaveTile = function(inst, slotnum)
		local widget = fn(inst, slotnum)
		local mode = GLOBAL.SaveGameIndex:GetCurrentMode(slotnum)
		local day = GLOBAL.SaveGameIndex:GetSlotDay(slotnum)
		if mode and mode:sub(1,4) == "age_" then
			local age = GLOBAL.tonumber(mode:sub(5,5))
			widget.text:SetString(GLOBAL.string.format("%s %d-%d",GLOBAL.STRINGS.UI.LOADGAMESCREEN.AGE, age, day))
		end
		return widget
	end
end)

AddClassPostConstruct("screens/slotdetailsscreen", function(self)
	local fn = self.BuildMenu
	self.BuildMenu = function(inst)
		fn(inst)
		local mode = GLOBAL.SaveGameIndex:GetCurrentMode(inst.saveslot)
		local day = GLOBAL.SaveGameIndex:GetSlotDay(inst.saveslot)
		local world = GLOBAL.SaveGameIndex:GetSlotWorld(inst.saveslot)
		if mode and mode:sub(1,4) == "age_" then
			local age = GLOBAL.tonumber(mode:sub(5,5))
			inst.text:SetString(GLOBAL.string.format("%s %d-%d",GLOBAL.STRINGS.UI.LOADGAMESCREEN.AGE, age, day))
		end
	end
end)

local fn = GLOBAL.TheSim.GenerateNewWorld
GLOBAL.getmetatable(GLOBAL.TheSim).__index.GenerateNewWorld = function(self, genparam, modparam, cb, ...)
	local json = GLOBAL.require("json")
	local data = json.decode(genparam)
	local ages = {}
	local file = "ageindex"
	print("Loading the Age Index") 
	self:GetPersistentString(file, function(load_success, str)
		local success, savedata = GLOBAL.RunInSandbox(str)
		if success and string.len(str) > 0 and savedata ~= nil then
			print("Loaded "..file)
			print("Successfully loaded the Age Index")
			for k,v in pairs(savedata.SLOTS) do
				ages[tostring(k)] = v.AGES
			end
		else
			print("Could not load "..file)
		end
	end)
	data.AGES = ages
	genparam = json.encode(data)
	return fn(self, genparam, modparam, cb, ...)
end

--This allows the Death Screen to open in all situations
AddComponentPostInit("clock",function(self)
	local fn_tometricsstring = self.ToMetricsString
	self.ToMetricsString = function(self)
		if GLOBAL.debug.getinfo(2).name == "HandleDeathCleanup" then
			local wilson = ({GLOBAL.debug.getlocal(2,1)})[2]
			local DeathScreen = require "screens/deathscreen"
			local default_modes = {
				survival=true,
				cave=true,
				volcano=true,
				shipwrecked=true,
				adventure=true
			}
			if not default_modes[GLOBAL.SaveGameIndex:GetCurrentMode()] then
				local playtime = GLOBAL.GetTimePlaying()
				playtime = math.floor(playtime*1000)
				GLOBAL.SetTimingStat("time", "scenario", playtime)
				GLOBAL.SendTrackingStats()
				local days_survived, start_xp, reward_xp, new_xp, capped = GLOBAL.CalculatePlayerRewards(wilson)
				
				GLOBAL.ProfileStatsSet("xp_gain", reward_xp)
				GLOBAL.ProfileStatsSet("xp_total", new_xp)
				GLOBAL.SubmitCompletedLevel()

				wilson.components.health.invincible = true

				wilson.profile:Save(function()
					GLOBAL.SaveGameIndex:EraseCurrent(function()
						GLOBAL.scheduler:ExecuteInTime(3, function()
							GLOBAL.TheFrontEnd:PushScreen(DeathScreen(days_survived, start_xp, nil, capped))
						end)
					end)
				end)
			end
		end
		return fn_tometricsstring(self)
	end
end)

--Makes the World Gen Screen act according to the world type
local Screen = require "widgets/screen"
local ctor_screen = Screen._ctor
Screen._ctor = function(self, name)
	ctor_screen(self,name)
	if name == "WorldGenScreen" then
		local _,world_gen_options = GLOBAL.debug.getlocal(2,4)
		local age_name = world_gen_options.level_type
		local world_type = GLOBAL.AgeIndex:GetAgeType(age_name)
		if world_type == "forest" then
			world_type = "survival"
		elseif world_type == "tropics" then
			world_type = "shipwrecked"
		end
		local accessors = 1
		if world_type == "volcano" then
			accessors = 2
		elseif world_type == "survival" then
			accessors = 3
		end
		local i = 0
		world_gen_options.level_type = nil
		GLOBAL.setmetatable(world_gen_options, {
			__index = function(t,k)
				if k == "level_type" then
					if i == accessors then
						i = i + 1
						return age_name
					else
						i = i + 1
						return world_type
					end
				end
			end
		})
	end
end

--Copies the contents of a table
function GLOBAL.Copy(src, dest)
	for k,v in pairs(src) do
		if type(v) == type({}) then
			dest[k] = {}
			GLOBAL.Copy(v, dest[k])
		else
			dest[k] = v
		end
	end
	return dest
end