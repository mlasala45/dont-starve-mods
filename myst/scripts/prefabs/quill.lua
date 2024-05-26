local Assets = {
	Asset("ANIM", "anim/quill.zip"),

	Asset("ATLAS", "images/quill.xml"),
	Asset("IMAGE", "images/quill.tex")
}

local function OnFinished(inst)
	inst:Remove()
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("quill")
	inst.AnimState:SetBuild("quill")
	inst.AnimState:PlayAnimation("idle")

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/quill.xml"
	inst.components.inventoryitem.imagename = "quill"
	
	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(TUNING.QUILL_USES)
	inst.components.finiteuses:SetUses(TUNING.QUILL_USES)
	inst.components.finiteuses:SetOnFinished(OnFinished)

	return inst
end

return Prefab("common/inventoryitems/quill", fn, Assets, {})