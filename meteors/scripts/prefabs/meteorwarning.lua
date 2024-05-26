local assets =
{
	Asset("ANIM", "anim/meteor_shadow.zip"),
}

local function AlphaToFade(alpha)
	return math.floor(alpha * 63 + .5)
end

local function FadeToAlpha(fade)
	return fade / 63
end

local function CalculatePeriod(time, starttint, endtint)
	return time / math.max(1, AlphaToFade(endtint) - AlphaToFade(starttint))
end

local DEFAULT_START = .33
local DEFAULT_END = 1
local DEFAULT_DURATION = 1
local DEFAULT_PERIOD = CalculatePeriod(DEFAULT_DURATION, DEFAULT_START, DEFAULT_END)

local function PushAlpha(inst)
	local alpha = FadeToAlpha(inst.fade)
	inst.AnimState:SetMultColour(alpha, alpha, alpha, alpha)
end

local function UpdateFade(inst)
	if inst.fade < inst.fadeend then
		inst.fade = inst.fade + 1
		PushAlpha(inst)
	end
	if inst.fade >= inst.fadeend and inst.task ~= nil then
		inst.task:Cancel()
		inst.task = nil
	end
end

local function OnFadeDirty(inst)
	PushAlpha(inst)
	if inst.task ~= nil then
		inst.task:Cancel()
	end
	inst.task = inst:DoPeriodicTask(inst.period, UpdateFade)
end

local function startshadow(inst, time, starttint, endtint)
	if time ~= DEFAULT_DURATION or starttint ~= DEFAULT_START or endtint ~= DEFAULT_END then
		inst.fade = AlphaToFade(starttint)
		inst.fadeend = AlphaToFade(endtint)
		inst.period = CalculatePeriod(time, starttint, endtint)
		OnFadeDirty(inst)
	end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	inst.AnimState:SetBank("warning_shadow")
	inst.AnimState:SetBuild("meteor_shadow")
	inst.AnimState:PlayAnimation("idle", true)
	inst.AnimState:SetFinalOffset(-1)

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.fade = AlphaToFade(DEFAULT_START)
	inst.fadeend = AlphaToFade(DEFAULT_END)
	inst.period = DEFAULT_PERIOD
	inst.task = nil
	OnFadeDirty(inst)

	inst.SoundEmitter:PlaySound("dontstarve/common/meteor_spawn")

	inst.startfn = startshadow

	inst.persists = false

	return inst
end

return Prefab("common/fx/meteorwarning", fn, assets)
