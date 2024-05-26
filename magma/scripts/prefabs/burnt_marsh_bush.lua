local assets =
{
	Asset("ANIM", "anim/marsh_bush.zip")
}

local prefabs =
{
	"twigs",
	"dug_marsh_bush"
}

local function burnt_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst.AnimState:SetBuild("marsh_bush")
	inst.AnimState:SetBank("marsh_bush")
	inst.AnimState:PlayAnimation("idle", true)

	inst:AddTag("thorny")

	inst.AnimState:SetTime(math.random()*2)

	local color = 0.5 + math.random() * 0.5
	inst.AnimState:SetMultColour(color, color, color, 1)

	inst:AddComponent("inspectable")

	inst.AnimState:PlayAnimation("burnt")
	inst:AddTag("burnt")

	return inst
end

return Prefab("burnt_marsh_bush", burnt_fn, assets, prefabs)