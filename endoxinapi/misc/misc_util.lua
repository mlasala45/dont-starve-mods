AddGlobalClassPostConstruct("frontend", "FrontEnd", function(self)
	--Returns the resolution of the game display. Information only valid in fullscreen.
	self.GetResolution = function(inst)
		local go = inst:GetGraphicsOptions()
		local id = go:GetFullscreenDisplayID()
		local mode_id = go:GetCurrentDisplayModeID(id)
		return go:GetDisplayMode(id, mode_id)
	end
end)

--Prints the stacktrace
function GLOBAL.PrintStackTrace()
	print(GLOBAL.debug.traceback())
end

--Gets the length of a table
function GLOBAL.GetLength(t)
	local count = 0
	for _ in pairs(t) do
		count= count + 1
	end
	return count
end

function GLOBAL.PopAndUnpause()
	GLOBAL.TheFrontEnd:PopScreen()
	GLOBAL.SetPause(false)
end

--Patch required for 'builder.lua' override in vanilla
if not GLOBAL.IsDLCEnabled(GLOBAL.CAPY_DLC) and not GLOBAL.IsDLCEnabled(GLOBAL.REIGN_OF_GIANTS) then
	AddComponentPostInit("inventory",function(self)
		function self:GetItemByName(item, amount)
			local total_num_found = 0
			local items = {}

			local function tryfind(v)
				local num_found = 0
				if v and v.prefab == item then
					local num_left_to_find = amount - total_num_found
					if v.components.stackable then
						if v.components.stackable.stacksize > num_left_to_find then
							items[v] = num_left_to_find
							num_found = amount
						else
							items[v] = v.components.stackable.stacksize
							num_found = num_found + v.components.stackable.stacksize
						end
					else
						items[v] = 1
						num_found = num_found + 1
					end
				end
				return num_found
			end

			for k = 1,self.maxslots do
				local v = self.itemslots[k]
				total_num_found = total_num_found + tryfind(v)
				if total_num_found >= amount then
					break
				end
			end
			
			if self.activeitem and self.activeitem.prefab == item and total_num_found < amount then
				total_num_found = total_num_found + tryfind(self.activeitem)
			end
			
			if self.overflow and total_num_found < amount then
				local overflow_items = self.overflow.components.container:GetItemByName(item, (amount - total_num_found))
				for k,v in pairs(overflow_items) do
					items[k] = v
				end
			end

			return items
		end
	end)
end