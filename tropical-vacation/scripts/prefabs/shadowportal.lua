local BigPopupDialogScreen = require "screens/popupdialog"
--local DropAllInvalidItems = require "itemfilter" --Is this still necessary?

require "prefabutil"

local Assets = {
	Asset("ANIM", "anim/shadow_portal.zip"),
}

local function GetVerb(inst)
	return "SHADOWPORTAL"
end

local function OnActivate(inst)
	if SaveGameIndex:GetCurrentMode() == "adventure" and not ALLOWADVENTUREPORTALS then
		GetPlayer().sg:GoToState("idle")
		GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, "ACTIONFAIL_ADVENTUREMODE"))
		inst.components.activatable.inactive = true
	else
		local onsave = function()
			SetPause(false)
			StartNextInstance(nil, true)
		end
		local fn
		if SaveGameIndex:GetCurrentMode() == "shipwrecked" then
			fn = function()
				SaveGameIndex:LeaveShipwrecked(onsave)
			end
		else
			fn = function()
				SaveGameIndex:EnterShipwrecked(onsave)
			end
		end

		SetPause(true, "portal")

		local desc = STRINGS.UI.SHADOWPORTAL.DESCRIBE_NODLC
		--[[if IsDLCEnabled(REIGN_OF_GIANTS) then
			desc = STRINGS.UI.SHADOWPORTAL.DESCRIBE_ROG
		elseif IsDLCEnabled(CAPY_DLC) then
			desc = STRINGS.UI.SHADOWPORTAL.DESCRIBE_SHIPWRECKED
		end]]
		
		local function dotravel()
			TheFrontEnd:PopScreen()
			SetPause(false)
			--DropAllInvalidItems(GetPlayer().components.inventory)
			GetPlayer().sg:GoToState("teleportato_teleport")
			GetPlayer():DoTaskInTime(5, function() SaveGameIndex:SaveCurrent(fn) end)
		end

		local function rejecttravel()
			TheFrontEnd:PopScreen()
			SetPause(false) 
			inst.components.activatable.inactive = true
		end
		TheFrontEnd:PushScreen(BigPopupDialogScreen(STRINGS.UI.SHADOWPORTAL.PROMPT, desc,
			{
				{text = STRINGS.UI.SHADOWPORTAL.BUTTON_YES, cb = dotravel},
				{text = STRINGS.UI.SHADOWPORTAL.BUTTON_NO, cb = rejecttravel}
			}))
	end
end

local function OnHammered(inst)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local minimap = inst.entity:AddMiniMapEntity()

	minimap:SetPriority(5)
	minimap:SetIcon("shadowportal.png")
	
	MakeObstaclePhysics(inst, .5)
	
	anim:SetBank("shadow_portal")
	anim:SetBuild("shadow_portal")
	anim:PlayAnimation("activate")
	anim:PushAnimation("idle_loop_on", true)
	
	inst:AddComponent("inspectable")
	inst.components.inspectable:SetDescription(function()
		if SaveGameIndex:GetCurrentMode() == "shipwrecked" then
			return STRINGS.CHARACTERS.GENERIC.DESCRIBE.SHADOWPORTAL.FOREST
		elseif SaveGameIndex:GetCurrentMode() == "adventure" and not ALLOWADVENTUREPORTALS then
			return STRINGS.CHARACTERS.GENERIC.DESCRIBE.SHADOWPORTAL.LOCKED
		else
			return STRINGS.CHARACTERS.GENERIC.DESCRIBE.SHADOWPORTAL.TROPICS
		end
	end)

	inst:AddComponent("activatable")
	inst.components.activatable.OnActivate = OnActivate
	inst.components.activatable.inactive = true
	inst.components.activatable.getverb = GetVerb
	inst.components.activatable.quickaction = true

	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(1)
	inst.components.workable:SetOnFinishCallback(OnHammered)

	sound:PlaySound("shadwell_sfx/examples/portal", "portal_loop")

	return inst
end

return Prefab("common/shadowportal", fn, Assets),
	MakePlacer("common/shadowportal_placer", "shadow_portal", "shadow_portal", "idle_off")