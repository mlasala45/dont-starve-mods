local assets = {
	Asset("ANIM", "anim/wall_moonrock.zip"),

	Asset("ATLAS", "images/wall_moonrock_item.xml"),
	Asset("IMAGE", "images/wall_moonrock_item.tex")
}

local function ondeploywall(inst, pt, deployer)
	local wall = SpawnPrefab("wall_moonrock") 
	if wall then 
		pt = Vector3(math.floor(pt.x)+.5, 0, math.floor(pt.z)+.5)
		wall.Physics:SetCollides(false)
		wall.Physics:Teleport(pt.x, pt.y, pt.z) 
		wall.Physics:SetCollides(true)
		inst.components.stackable:Get():Remove()

		local ground = GetWorld()
		if ground then
			ground.Pathfinder:AddWall(pt.x, pt.y, pt.z)
		end
	end 		
end

local function onhammered(inst, worker)
	local num_loots = math.max(1, math.floor(2*inst.components.health:GetPercent()))
	for k = 1, num_loots do
		inst.components.lootdropper:SpawnLootPrefab("moonrocknugget")
	end		
	
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	
	inst:Remove()
end



local function test_wall(inst, pt)
	local tiletype = GetGroundTypeAtPosition(pt)
	local ground_OK = tiletype ~= GROUND.IMPASSABLE 
	
	if ground_OK then
		local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 2, nil, {"NOBLOCK", "player", "FX", "INLIMBO", "DECOR"}) -- or we could include a flag to the search?

		for k, v in pairs(ents) do
			if v ~= inst and v.entity:IsValid() and v.entity:IsVisible() and not v.components.placer and v.parent == nil then
				local dsq = distsq( Vector3(v.Transform:GetWorldPosition()), pt)
				if v:HasTag("wall") then
					if dsq < .1 then return false end
				else
					if  dsq< 1 then return false end
				end
			end
		end
		
		return true
	end
	return false
end

local function makeobstacle(inst)
	inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)	
	inst.Physics:ClearCollisionMask()
	inst.Physics:SetMass(0)
	inst.Physics:CollidesWith(COLLISION.ITEMS)
	inst.Physics:CollidesWith(COLLISION.CHARACTERS)
	inst.Physics:SetActive(true)
	local ground = GetWorld()
	if ground then
		local pt = Point(inst.Transform:GetWorldPosition())
		ground.Pathfinder:AddWall(pt.x, pt.y, pt.z)
	end
end

local function clearobstacle(inst)
	inst:DoTaskInTime(2*FRAMES, function() inst.Physics:SetActive(false) end)

	local ground = GetWorld()
	if ground then
		local pt = Point(inst.Transform:GetWorldPosition())
		ground.Pathfinder:RemoveWall(pt.x, pt.y, pt.z)
	end
end

local anims = {
	{ threshold = 0, anim = "broken" },
	{ threshold = 0.4, anim = "onequarter" },
	{ threshold = 0.5, anim = "half" },
	{ threshold = 0.99, anim = "threequarter" },
	{ threshold = 1, anim = { "fullA", "fullB", "fullC" } }
}

local function resolveanimtoplay(inst, percent)
	for i, v in ipairs(anims) do
		if percent <= v.threshold then
			if type(v.anim) == "table" then
				local x, y, z = inst.Transform:GetWorldPosition()
				local x = math.floor(x)
				local z = math.floor(z)
				local q1 = #v.anim + 1
				local q2 = #v.anim + 4
				local t = ( ((x%q1)*(x+3)%q2) + ((z%q1)*(z+3)%q2) )% #v.anim + 1
				return v.anim[t]
			else
				return v.anim
			end
		end
	end
end

local function onhealthchange(inst, old_percent, new_percent)
	
	if old_percent <= 0 and new_percent > 0 then makeobstacle(inst) end
	if old_percent > 0 and new_percent <= 0 then clearobstacle(inst) end

	local anim_to_play = resolveanimtoplay(inst, new_percent)
	if new_percent > 0 then
		inst.AnimState:PlayAnimation(anim_to_play.."_hit")		
		inst.AnimState:PushAnimation(anim_to_play, false)		
	else
		inst.AnimState:PlayAnimation(anim_to_play)		
	end
end

local function itemfn(Sim)

	local inst = CreateEntity()
	inst:AddTag("wallbuilder")
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBank("wall_moonrock")
	inst.AnimState:SetBuild("wall_moonrock")
	inst.AnimState:PlayAnimation("idle")

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "wall_moonrock_item"
	inst.components.inventoryitem.atlasname = "images/wall_moonrock_item.xml"
	
	inst:AddComponent("repairer")

	inst.components.repairer.repairmaterial = "moonrock"

	inst.components.repairer.healthrepairvalue = TUNING.MOONROCKWALL_HEALTH / 6
		
	inst:AddComponent("deployable")
	inst.components.deployable.ondeploy = ondeploywall
	inst.components.deployable.test = test_wall
	inst.components.deployable.min_spacing = 0
	inst.components.deployable.placer = "wall_moonrock_placer"
	
	return inst
end

local function onhit(inst)
	local healthpercent = inst.components.health:GetPercent()
	local anim_to_play = resolveanimtoplay(inst, healthpercent)
	if healthpercent > 0 then
		inst.AnimState:PlayAnimation(anim_to_play.."_hit")		
		inst.AnimState:PushAnimation(anim_to_play, false)	
	end	

end

local function onrepaired(inst)
	inst.SoundEmitter:PlaySound("dontstarve/common/place_structure_stone")
	makeobstacle(inst)
end
	
local function onload(inst, data)
	makeobstacle(inst)
	if inst.components.health:GetPercent() <= 0 then
		clearobstacle(inst)
	end
end

local function onremoveentity(inst)
	clearobstacle(inst)
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	inst:AddTag("wall")

	MakeObstaclePhysics(inst, .5)
	inst.entity:SetCanSleep(false)

	anim:SetBank("wall_moonrock")
	anim:SetBuild("wall_moonrock")
	anim:PlayAnimation("half", false)
	
	inst:AddComponent("inspectable")
	inst:AddComponent("lootdropper")
	
	inst:AddTag("stone")
	inst:AddTag("moonrock")
			
	inst:AddComponent("repairable")

	inst.components.repairable.repairmaterial = "moonrock"

	inst.components.repairable.onrepaired = onrepaired
	
	inst:AddComponent("combat")
	inst.components.combat.onhitfn = onhit
	
	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(TUNING.MOONROCKWALL_HEALTH)
	inst.components.health.currenthealth = TUNING.MOONROCKWALL_HEALTH / 2
	inst.components.health.ondelta = onhealthchange
	inst.components.health.nofadeout = true
	inst.components.health.canheal = false
	inst.components.health.playerabsorb = TUNING.MOONROCKWALL_PLAYERDAMAGEMOD

	inst:AddTag("noauradamage")

	inst.components.health.fire_damage_scale = 0

	inst.SoundEmitter:PlaySound("dontstarve/common/place_structure_stone")		
	
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(TUNING.MOONROCKWALL_WORK)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit) 
			
	
	inst.OnLoad = onload
	inst.OnRemoveEntity = onremoveentity
	
	MakeSnowCovered(inst)
	
	return inst
end


return Prefab( "common/wall_moonrock", fn, assets),
	   Prefab( "common/wall_moonrock_item", itemfn, assets, {"wall_moonrock", "wall_moonrock_placer"}),
	   MakePlacer("common/wall_moonrock_placer", "wall_moonrock", "wall_moonrock", "half", false, false, true)