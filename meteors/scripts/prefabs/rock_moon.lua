local rock_moon_assets =
{
	Asset("ANIM", "anim/rock7.zip"),
}

local prefabs =
{
	"rocks",
	"nitre",
	"flint",
	"goldnugget",
	"moonrocknugget",
}

SetSharedLootTable( 'rock_moon',
{
	{'rocks',           1.00},
	{'rocks',           1.00},
	{'moonrocknugget',  1.00},
	{'flint',           1.00},
	{'moonrocknugget',  0.25},
	{'flint',           0.60},
})

local function OnWork(inst, worker, workleft)
	local pt = Point(inst.Transform:GetWorldPosition())
	if workleft <= 0 then
		inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
		inst.components.lootdropper:DropLoot(pt)
		inst:Remove()
	elseif workleft < TUNING.ROCKS_MINE / 3 then
		inst.AnimState:PlayAnimation("low")
	elseif workleft < TUNING.ROCKS_MINE * 2 / 3 then
		inst.AnimState:PlayAnimation("med")
	else
		inst.AnimState:PlayAnimation("full")
	end
end

local function baserock_fn(bank, build, anim, icon)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()

	MakeObstaclePhysics(inst, 1)

	inst.MiniMapEntity:SetIcon(icon or "rock.png")

	inst.AnimState:SetBank(bank)
	inst.AnimState:SetBuild(build)
	inst.AnimState:PlayAnimation(anim)

	inst:AddTag("boulder")

	inst:AddComponent("lootdropper") 

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.MINE)
	inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)
	inst.components.workable:SetOnWorkCallback(OnWork)

	local color = 0.5 + math.random() * 0.5
	inst.AnimState:SetMultColour(color, color, color, 1)

	inst:AddComponent("inspectable")
	inst.components.inspectable.nameoverride = "ROCK"
	MakeSnowCovered(inst)

	return inst
end

local function rock_moon()
	local inst = baserock_fn("rock5", "rock7", "full")

	inst.components.lootdropper:SetChanceLootTable('rock_moon')

	return inst
end


return Prefab("forest/objects/rocks/rock_moon", rock_moon, rock_moon_assets, prefabs)