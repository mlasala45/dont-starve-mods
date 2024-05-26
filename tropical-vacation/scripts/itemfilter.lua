local DoNotStarve = require "items_dontstarve"
local ReignOfGiants = require "items_reignofgiants"
local Shipwrecked = require "items_shipwrecked"

--Not actually 100% accurate, but it still works
local ThisDLC = DoNotStarve
local OtherDLC = Shipwrecked
if IsDLCEnabled(CAPY_DLC) then
	ThisDLC = Shipwrecked
	if IsDLCInstalled(REIGN_OF_GIANTS) then
		OtherDLC = ReignOfGiants
	else
		OtherDLC = DoNotStarve
	end
elseif IsDLCEnabled(REIGN_OF_GIANTS) then
	ThisDLC = ReignOfGiants
	OtherDLC = Shipwrecked
end

local function ListToTable(list)
	local table = {}
	for _,v in ipairs(list) do
		table[v] = true
	end
	return table
end

ThisDLC = ListToTable(ThisDLC)
OtherDLC = ListToTable(OtherDLC)

local TransferrableItems = {}
for k,_ in pairs(ThisDLC) do
	if OtherDLC[k] then
		TransferrableItems[k] = true
	end
end

local function AddTransferrableItem(prefab)
	TransferrableItems[prefab] = true
end

local function DropAllInvalidItemsFromContainer(inv)
	for k = 1,inv.numslots do
		local v = inv.slots[k]
		if v then
			if v.components.container then
				DropAllInvalidItems(v.components.container)
			end
			if not TransferrableItems[v.prefab] then
				local item = inv:RemoveItemBySlot(k)
				if item then
					local pos = Vector3(inv.inst.Transform:GetWorldPosition())
					item.Transform:SetPosition(pos:Get())
					if item.components.inventoryitem then
						item.components.inventoryitem:OnDropped(true)
					end
					inv.inst:PushEvent("dropitem", {item = item})
				end
			end
		end
	end
end

local function DropAllInvalidItems(inv)
	if inv.activeitem and not TransferrableItems[inv.activeitem.prefab] then
		inv:DropItem(inv.activeitem)
		inv:SetActiveItem(nil)
	end

	for k = 1,inv.maxslots do
		local v = inv.itemslots[k]
		if v then
			if v.components.container then
				DropAllInvalidItemsFromContainer(v.components.container)
			end
			if not TransferrableItems[v.prefab] then
				inv:DropItem(v, true, true)
			end
		end
	end

	for k,v in pairs(inv.equipslots) do
		if v then
			if v.components.container then
				DropAllInvalidItemsFromContainer(v.components.container)
			end
			if not TransferrableItems[v.prefab] then
				inv:DropItem(v, true, true)
			end
		end
	end
end

return DropAllInvalidItems, AddTransferrableItem