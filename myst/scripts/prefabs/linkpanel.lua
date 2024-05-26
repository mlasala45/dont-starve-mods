local Assets = {
	Asset("ANIM", "anim/linkpanel.zip"),

	Asset("ATLAS", "images/linkpanel.xml"),
	Asset("IMAGE", "images/linkpanel.tex")
}

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	anim:SetBank("linkpanel")
	anim:SetBuild("linkpanel")
	anim:PlayAnimation("idle")

	MakeInventoryPhysics(inst)
	
	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/linkpanel.xml"
	inst.components.inventoryitem.imagename = "linkpanel"

	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)

	return inst
end

return Prefab("common/linkpanel", fn, Assets) 