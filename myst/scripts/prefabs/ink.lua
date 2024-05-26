local Assets = {
	Asset("ANIM", "anim/ink.zip"),
    Asset("ANIM", "anim/explode.zip"),

	Asset("ATLAS", "images/ink.xml"),
	Asset("IMAGE", "images/ink.tex")
}

local Prefabs = {
	"explode_small"
}

local function OnIgniteFn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")
end

local function OnExplodeFn(inst)
    local pos = Vector3(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:KillSound("hiss")
    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")

    local explode = SpawnPrefab("explode_small")
    local pos = inst:GetPosition()
    explode.Transform:SetPosition(pos.x, pos.y, pos.z)

    explode.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
    explode.AnimState:SetLightOverride(1)
end

local function OnDrinkFn(inst, doer)
	if doer.components.health then
		doer.components.health:DoDelta(-TUNING.HEALING_LARGE)
	end
	if doer.components.hunger then
		doer.components.hunger:DoDelta(-TUNING.CALORIES_TINY)
	end
	if doer.components.sanity then
		doer.components.sanity:DoDelta(-TUNING.SANITY_LARGE)
	end
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("ink")
	inst.AnimState:SetBuild("ink")
	inst.AnimState:PlayAnimation("idle")

	inst:AddComponent("inspectable")

	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)
	
	inst:AddComponent("explosive")
	inst.components.explosive:SetOnExplodeFn(OnExplodeFn)
	inst.components.explosive:SetOnIgniteFn(OnIgniteFn)
	inst.components.explosive.explosivedamage = TUNING.INK_DAMAGE

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/ink.xml"
	inst.components.inventoryitem.imagename = "ink"

	if IsDLCEnabled(CAPY_DLC) then
		inst:AddComponent("drinkable")
		inst.components.drinkable.ondrinkfn = OnDrinkFn
		inst.components.drinkable.quaff = function(inst, doer)
			if doer.components.sanity then
				return doer.components.sanity:IsCrazy()
			else
				return false
			end
		end
	end
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	return inst
end

return Prefab("common/inventoryitems/ink", fn, Assets, Prefabs)