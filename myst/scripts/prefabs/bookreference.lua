--[[
-- INCOMPLETE
--]]

local Assets = {
	Asset("ATLAS", "images/worldbook.xml"),
	Asset("IMAGE", "images/worldbook.tex")
}

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()

	MakeInventoryPhysics(inst)
	
	inst:AddComponent("inspectable")

	inst:AddComponent("bookreference")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/worldbook.xml"
	inst.components.inventoryitem.imagename = "worldbook"

	return inst
end

return Prefab("common/worldbook", fn, Assets)