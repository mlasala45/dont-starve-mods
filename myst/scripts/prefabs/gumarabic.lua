local Assets = {
	Asset("ANIM", "anim/gumarabic.zip"),

	Asset("ATLAS", "images/gumarabic.xml"),
	Asset("IMAGE", "images/gumarabic.tex")
}

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("gumarabic")
	inst.AnimState:SetBuild("gumarabic")
	inst.AnimState:PlayAnimation("idle")

	inst:AddComponent("inspectable")

	inst:AddTag("grindable")
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/gumarabic.xml"
	inst.components.inventoryitem.imagename = "gumarabic"

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_PRESERVED)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
	inst:AddTag("show_spoilage")

	inst:AddComponent("edible")
	inst.components.edible.hungervalue = TUNING.CALORIES_TINY
	inst.components.edible.healthvalue = TUNING.HEALING_TINY
	inst.components.edible.foodtype = "RAW"
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("fuel")
	inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

	MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
	MakeSmallPropagator(inst)

	return inst
end

return Prefab("common/inventoryitems/gumarabic", fn, Assets, {})