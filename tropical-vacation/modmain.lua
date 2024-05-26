if GLOBAL.IsDLCInstalled(GLOBAL.CAPY_DLC) then
	GLOBAL.ALLOWADVENTUREPORTALS = GetModConfigData("ALLOWADVENTUREPORTALS")
	GLOBAL.CRAFTINGLEVEL = GetModConfigData("CRAFTINGLEVEL")
	GLOBAL.PORTALNOISE = GetModConfigData("PORTALNOISE")

	PrefabFiles = {
		"shadowportal"
	}

	Assets = {
		Asset("ATLAS", "images/shadowportal.xml"),
		Asset("IMAGE", "images/shadowportal.tex"),

		Asset("SOUNDPACKAGE", "sound/shadwell_sfx.fev"),
		Asset("SOUND", "sound/shadwell_sfx.fsb"),

		Asset("ATLAS", "minimap/shadowportal.xml"),
		Asset("IMAGE", "minimap/shadowportal.tex")
	}

	AddMinimapAtlas("minimap/shadowportal.xml")

	local require = GLOBAL.require
	require "tropicalvacation_strings"
	if GLOBAL.IsDLCEnabled(GLOBAL.CAPY_DLC) then
		require "tropicalvacation_recipes_shipwrecked"
	else
		require "tropicalvacation_recipes_normal"
	end

	AddGlobalClassPostConstruct("saveindex", "SaveIndex", function(self)
		self.GetOtherSlot = function(self, slot)
			slot = slot or self:GetCurrentSaveSlot()
			if slot <= 5 then
				slot = slot + 5
			else
				slot = slot - 5
			end
			return slot
		end

		local fn = self.DeleteSlot
		self.DeleteSlot = function(self, slot, cb, save_options, exclude_other)
			if not self.data.slots[slot] then
				self.data.slots[slot] = { modes={} }
			end
			if not exclude_other then
				self:DeleteSlot(self:GetOtherSlot(slot), nil, nil, true)
			end
			fn(self, slot, cb, save_options)
		end

		self.SetPlayerData = function(self, slot, mode, data)
			slot = slot or self.current_slot
			self:GetModeData(slot, mode or self.data.slots[slot].current_mode).playerdata = data
		end

		self.GetCurrentModeSafely = function(self, slot)
			if self.data.slots[slot or self.current_slot] then
				return self.data.slots[slot or self.current_slot].current_mode
			else
				print("Data for slot "..(slot or self.current_slot).." missing!")
			end
		end

		self.HasWorldSafe = function(self, slot, mode)
			slot = slot or self.current_slot
			if self.data.slots[slot] then
				local current_mode = mode or self.data.slots[slot].current_mode
				local data = self:GetModeData(slot, current_mode)
				return data.file ~= nil
			else
				print("Data for slot "..slot.." missing!")
				return false
			end
		end

		self.LeaveShipwrecked = function(self, onsavedcb)
			local slot = self:GetCurrentSaveSlot()
			local otherslot = self:GetOtherSlot()
			local character = self:GetSlotCharacter(slot)
			local rog = GLOBAL.IsDLCInstalled(GLOBAL.REIGN_OF_GIANTS)
			if slot <= 5 then
				self.data.slots[slot].otherslot = true
			else
				self.data.slots[otherslot].otherslot = false
			end
			local function cb()
				self:SetPlayerData(otherslot, self:GetCurrentModeSafely(otherslot) or "survival", GLOBAL.GetPlayer():GetPersistData())
				self:Save(onsavedcb)
			end
			self:SaveCurrent()
			if not self:HasWorldSafe(otherslot, self:GetCurrentModeSafely(otherslot)) then
				self:StartSurvivalMode(otherslot, character, nil, cb, {REIGN_OF_GIANTS=rog, CAPY_DLC=false, CapyDLC=false}, "survival")
			else
				cb()
			end
		end

		self.EnterShipwrecked = function(self, onsavedcb)
			local slot = self:GetCurrentSaveSlot()
			local otherslot = self:GetOtherSlot()
			local character = self:GetSlotCharacter(slot)
			if slot <= 5 then
				self.data.slots[slot].otherslot = true
			else
				self.data.slots[otherslot].otherslot = false
			end
			GLOBAL.DisableDLC(GLOBAL.REIGN_OF_GIANTS)
			GLOBAL.EnableDLC(GLOBAL.CAPY_DLC)
			local function cb()
				self:SetPlayerData(otherslot, self:GetCurrentModeSafely(otherslot) or "shipwrecked", GLOBAL.GetPlayer():GetPersistData())
				self:Save(onsavedcb)
			end
			self:SaveCurrent()
			if not self:HasWorldSafe(otherslot, "shipwrecked") then
				self:StartSurvivalMode(otherslot, character, nil, cb, {REIGN_OF_GIANTS=false, CAPY_DLC=true, CapyDLC=true}, "shipwrecked")
			else
				cb()
			end
		end
	end)

	AddClassPostConstruct("screens/loadgamescreen", function(self)
		local fn_makesavetile = self.MakeSaveTile
		self.MakeSaveTile = function(self, slotnum)
			if GLOBAL.SaveGameIndex.data.slots[slotnum].otherslot then
				slotnum = GLOBAL.SaveGameIndex:GetOtherSlot(slotnum)
			end
			return fn_makesavetile(self, slotnum)
		end

		self.OnBecomeActive = function(self)
			if self.last_slotnum and self.last_slotnum > 5 then
				self.last_slotnum = self.last_slotnum - 5
			end
			self:RefreshFiles()
			self._base.OnBecomeActive(self)
			if self.last_slotnum then
				self.menu.items[self.last_slotnum]:SetFocus()
			end
		end

		local mt = {}
		mt.__index = function(t,k)
			return t[GLOBAL.SaveGameIndex:GetOtherSlot(k)]
		end

		local fn_clear = self.menu.Clear
		self.menu.Clear = function(self)
			fn_clear(self)
			GLOBAL.setmetatable(self.items,mt)
		end
	end)
end