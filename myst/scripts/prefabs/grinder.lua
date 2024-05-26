local Assets = {
	Asset("ANIM", "anim/grinder.zip"),
	Asset("ANIM", "anim/ui_grinder.zip"),

	Asset("ATLAS", "images/grinder.xml"),
	Asset("IMAGE", "images/grinder.tex")
}

local function OnFinished(inst)
	inst:Remove()
end

local function OnClose(inst)
	local item = inst.components.container:GetItemInSlot(1)
	if item then
		GetPlayer().components.inventory:GiveItem(item)
	end
end

local function OnDropped(inst)
	inst.components.container:Close()
end

local function TestFn(inst, item, slot)
	return item:HasTag("grindable")
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("grinder")
	inst.AnimState:SetBuild("grinder")
	inst.AnimState:PlayAnimation("idle")

	inst:AddComponent("inspectable")

	inst:AddComponent("handheldcontainer")

	inst:AddComponent("container")
	inst.components.container:SetNumSlots(1)
	inst.components.container.onclosefn = OnClose
	inst.components.container.itemtestfn = TestFn
	inst.components.container.acceptsstacks = true
	inst.components.container.widgetslotpos = {Vector3(0,20,0)}
	inst.components.container.widgetpos = Vector3(0,160,0)
	inst.components.container.side_align_tip = 200
	inst.components.container.widgetanimbank = "ui_grinder"
	inst.components.container.widgetanimbuild = "ui_grinder"
	inst.components.container.type = "handheld"
	inst.components.container.widgetbuttoninfo = {
		text = STRINGS.UI.GRIND,
		position = Vector3(0, -35, 0),
		fn = function(inst)
			local item = inst.components.container:GetItemInSlot(1)
			local taken
			if item.components.stackable then
				taken = item.components.stackable:Get(inst.components.finiteuses:GetUses())
			else
				taken = inst.components.container:RemoveItemBySlot(1)
			end
			local num = (taken.components.stackable and taken.components.stackable:StackSize()) or 1
			local ground_item = SpawnPrefab(item.prefab.."_ground")
			ground_item:RemoveFromScene()
			if ground_item.components.stackable then
				ground_item.components.stackable:SetStackSize(num)
			end
			taken:Remove()
			GetPlayer().components.inventory:GiveItem(ground_item)
			inst.components.finiteuses:Use(num)
		end,
		
		validfn = function(inst)
			local item = inst.components.container:GetItemInSlot(1)
			return item and item:HasTag("grindable")
		end,
	}

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.ondropfn = OnDropped
	inst.components.inventoryitem.atlasname = "images/grinder.xml"
	inst.components.inventoryitem.imagename = "grinder"
	
	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(TUNING.GRINDER_USES)
	inst.components.finiteuses:SetUses(TUNING.GRINDER_USES)
	inst.components.finiteuses:SetOnFinished(OnFinished)

	return inst
end

return Prefab("common/inventoryitems/grinder", fn, Assets)