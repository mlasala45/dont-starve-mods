GLOBAL.AddGlobalClassPostConstruct = AddGlobalClassPostConstruct
GLOBAL.AddPlayerPostInit = AddPlayerPostInit

GLOBAL.setfenv(1, GLOBAL)

AddPlayerPostInit(function(inst)
	inst:AddComponent("teleportonload")
end)

AddGlobalClassPostConstruct("saveindex", "SaveIndex", function(self)
	--Sends the player to a specified dimension
	function self:GoToDimension(dimname, x, y, z, save)
		self:SaveCurrent(function()
			--Records player data
			local playerdata = {}
			local player = GetPlayer()
			if player then
				if x or y or z then
					player.components.teleportonload:SetTarget(x,y,z)
				end
				playerdata = player:GetSaveRecord().data
				playerdata.leader = nil
				playerdata.sanitymonsterspawner = nil
			end

			--Ensures dimension designations are present (modename is mostly redundant, but whatever)
			dimname = dimname or "forest"
			local modename = dimname
			if dimname == "forest" then
				modename = "survival"
			elseif dimname == "tropics" then
				modename = "shipwrecked"
			end

			--Sets new mode
			self.data.slots[self.current_slot].current_mode = modename
			
			--Ensures mode data table is present
			if not self.data.slots[self.current_slot].modes[modename] then
				self.data.slots[self.current_slot].modes[modename] = {}
			end

			--Ensures mode data is present
			self.data.slots[self.current_slot].modes[modename].files = self.data.slots[self.current_slot].modes[modename].files or {}

			--Sets mode data
			self.data.slots[self.current_slot].modes[modename].world = 1
			
			--Generates save name
			local savename = self:GetSaveGameName(modename, self.current_slot)

			--Records player data to mode data
			self.data.slots[self.current_slot].modes[modename].playerdata = playerdata

			--Clears mode data file name entry
			self.data.slots[self.current_slot].modes[modename].file = nil
			
			--Checks if save exists
			TheSim:CheckPersistentStringExists(savename, function(exists)
				if exists then
					--Records save name to mode data
					self.data.slots[self.current_slot].modes[modename].file = savename
				end
			end)

			--Save
			self:Save(function()
				SetPause(false)
				StartNextInstance({reset_action=RESET_ACTION.LOAD_SLOT, save_slot = SaveGameIndex:GetCurrentSaveSlot()}, true)
			end)
		end)
	end
end)

--The only way I could find to get at the code that spawns the world prefab. Uses witchcraft to fetch the correct prefab, and returns it instead of the default.
local fn = SpawnPrefab
SpawnPrefab = function(name)
	if name == "forest" then
		print("Attempt to spawn 'forest' prefab")
		local _,savedata = debug.getlocal(2, 1) --Witchcraft!
		if type(savedata) == "table" and savedata.map and savedata.map.prefab then
			print("Alternative prefab detected:",savedata.map.prefab)
			if PrefabExists(savedata.map.prefab) then
				print("Using alternative prefab")
				name = savedata.map.prefab
			end
		end
	end
	return fn(name)
end