local assets =
{
	Asset("ANIM", "anim/burntground.zip"),
}

local FADE_INTERVAL = TUNING.TOTAL_DAY_TIME * 5 / 64 --64 ticks for smallbyte

local function OnFadeDirty(inst)
	local alpha = (64 - inst.fade) / 65
	inst.AnimState:SetMultColour(alpha, alpha, alpha, alpha)
end

local function UpdateFade(inst)
	if inst.fade < 63 then
		inst.fade = inst.fade + 1
		OnFadeDirty(inst)
	else
		inst:Remove()
	end
end

local function OnSave(inst, data)
	data.fade = inst.fade > 0 and inst.fade or nil
	data.rotation = inst.Transform:GetRotation()
	data.scale = { inst.Transform:GetScale() }
end

local function OnLoad(inst, data)
	if data ~= nil then
		if data.rotation ~= nil then
			inst.Transform:SetRotation(data.rotation)
		end
		if data.scale ~= nil then
			inst.Transform:SetScale(data.scale[1] or 1, data.scale[2] or 2, data.scale[3] or 3)
		end
		if data.fade ~= nil and data.fade > 0 then
			inst.fade = math.min(data.fade, 63)
			OnFadeDirty(inst)
		end
	end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst.AnimState:SetBuild("burntground")
	inst.AnimState:SetBank("burntground")
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)

	inst:AddTag("NOCLICK")
	inst:AddTag("FX")

	inst.fade = 0
	OnFadeDirty(inst)

	inst:DoPeriodicTask(FADE_INTERVAL, UpdateFade, math.max(0, FADE_INTERVAL - math.random()))

	inst.Transform:SetRotation(math.random() * 360)

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad

	return inst
end

return Prefab("common/objects/burntground", fn, assets)
