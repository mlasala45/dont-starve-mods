local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()

    inst:AddTag("CLASSIFIED")

    inst:AddComponent("meteorshower")

    return inst
end

return Prefab("common/objects/meteorspawner", fn)