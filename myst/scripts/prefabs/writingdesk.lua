local EditTableScreen = require "screens/edittablescreen"

local Assets = {
	Asset("ANIM", "anim/writingdesk.zip"),
	Asset("ANIM", "anim/ui_writingdesk.zip")
}

local function OnHammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function UpdateAnim(inst)
	local book = inst.components.container:GetItemInSlot(1)
	local quill = inst.components.container:GetItemInSlot(2)
	local anim = "idle"
	if book then
		anim = book.prefab
		if quill then
			anim = anim.."_quill"
		end
	elseif quill then
		anim = "quill"
	end
	
	inst.AnimState:PlayAnimation(anim)
end

local function TestFn(inst, item, slot)
	if slot == 1 then
		return item.prefab == "worldbook"
	elseif slot == 2 then
		return item.prefab == "quill"
	else
		return false
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	local minimap = inst.entity:AddMiniMapEntity()

	MakeObstaclePhysics(inst, .4)

	minimap:SetIcon("writingdesk.png")

	inst:AddTag("structure")
	inst:AddTag("prototyper")

	inst.AnimState:SetBank("writingdesk")
	inst.AnimState:SetBuild("writingdesk")
	inst.AnimState:PlayAnimation("idle")
	
	inst:AddComponent("inspectable")

	inst:AddComponent("container")
	inst.components.container:SetNumSlots(2)
	inst.components.container.itemtestfn = TestFn
	inst.components.container.acceptsstacks = false
	inst.components.container.widgetslotpos = {Vector3(-55,20,0), Vector3(55,20,0)}
	inst.components.container.widgetpos = Vector3(0,160,0)
	inst.components.container.side_align_tip = 200
	inst.components.container.widgetanimbank = "ui_writingdesk"
	inst.components.container.widgetanimbuild = "ui_writingdesk"
	inst.components.container.type = "writingdesk"
	inst.components.container.widgetbuttoninfo = {
		text = STRINGS.UI.WRITE,
		position = Vector3(0, -35, 0),
		fn = function(inst)
			local item = inst.components.container:GetItemInSlot(1)
			if item.prefab == "worldbook" then
				local data = item.components.worldbook.data
				local cb = function(self)
					item.components.worldbook.data = self.data
				end
				TheFrontEnd:PushScreen(EditTableScreen(data, TEMPLATES.WORLDBOOK, cb))
			end
		end,
		
		validfn = function(inst)
			local item1 = inst.components.container:GetItemInSlot(1)
			local item2 = inst.components.container:GetItemInSlot(2)
			local bookvalid = item1 and item1.prefab == "worldbook" and not item1:HasTag("finalised")
			local inkvalid = item2 and true
			return bookvalid and inkvalid
		end,
	}

	inst:AddComponent("prototyper")
	inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.WRITINGDESK

	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(2)
	inst.components.workable:SetOnFinishCallback(OnHammered)

	MakeLargeBurnable(inst, nil, nil, true)
	MakeLargePropagator(inst)
	
	inst:ListenForEvent("itemget", UpdateAnim)
	inst:ListenForEvent("itemlose", UpdateAnim)

	return inst
end

return Prefab("common/writingdesk", fn, Assets),
	MakePlacer("common/writingdesk_placer", "writingdesk", "writingdesk", "idle")