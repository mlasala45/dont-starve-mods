local assets =
{
	Asset("ANIM", "anim/moonrock_nugget.zip"),

	Asset("ATLAS", "images/moonrocknugget.xml"),
	Asset("IMAGE", "images/moonrocknugget.tex")
}

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetRayTestOnBB(true)
	inst.AnimState:SetBank("moonrocknugget")
	inst.AnimState:SetBuild("moonrock_nugget")
	inst.AnimState:PlayAnimation("idle")

	inst:AddComponent("edible")
	inst.components.edible.foodtype = "ELEMENTAL"
	inst.components.edible.hungervalue = 1
	inst:AddComponent("tradable")

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "moonrocknugget"
	inst.components.inventoryitem.atlasname = "images/moonrocknugget.xml"

	inst:AddComponent("repairer")
	inst.components.repairer.repairmaterial = "moonrock"
	inst.components.repairer.healthrepairvalue = TUNING.REPAIR_ROCKS_HEALTH

	return inst
end

return Prefab("common/inventory/moonrocknugget", fn, assets)