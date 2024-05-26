local Assets = {
	Asset("ANIM", "anim/books.zip"),

	Asset("ATLAS", "images/worldbook.xml"),
	Asset("IMAGE", "images/worldbook.tex"),

	Asset("SOUNDPACKAGE", "sound/myst.fev"),
	Asset("SOUND", "sound/myst.fsb")
}

local function UseFn(inst, reader)
	if inst:HasTag("finalised") then
		reader.sg:GoToState("still")
		reader.components.mystfader:Fade(false, 1, function()
			TheFrontEnd:Fade(false, 2)
			inst.components.inventoryitem:GetContainer():DropItem(inst)
			GetWorld():DoTaskInTime(2, function()
				AgeIndex:OnBookUse(inst)
			end)
		end)
		inst.SoundEmitter:PlaySound("myst/common/link")
	elseif reader.components.inventory then
		if inst.components.inkuser:UseInk(reader) then
			inst:AddTag("finalised")
			inst:AddComponent("named")
			inst.components.named:SetName('\"'..inst.components.worldbook.data.name..'\"')
			if reader.components.talker then
				reader.components.talker:Say(string.format(STRINGS.CHARACTERS.GENERIC.ANNOUNCE_WORLDBOOKFINISHED,inst.name))
			end
		end
	end
	return true
end

local slotpos = {}
for y = 2.5, -0.5, -1 do
	for x = 0, 2 do
		table.insert(slotpos, Vector3(75*x-75*2+75, 75*y-75*2+75,0))
	end
end

local function TestFn(inst, item, slot)
	if item:HasTag("symbol") then
		return true
	end
	return false
end

local function OnSave(inst, data)
	data.finalised = inst:HasTag("finalised")
	data.linked = inst:HasTag("linked")
	if inst.components.named then
		data.name = inst.name
	end

end

local function OnLoad(inst, data)
	if data then
		if data.finalised then
			inst:AddTag("finalised")
		end
		if data.linked then
			inst:AddTag("linked")
		end
		if data.named then
			inst:AddComponent("named")
			inst.components.named:SetName(data.name)
		end
	end
end

local function OnRemove(inst)
	if inst:HasTag("finalised") then
		local id = inst.components.worldbook:GetUID()
		local age = AgeIndex:GetCurrentAge()
		if id == age then
			AgeIndex:MarkAgeForDeath(id)
			AgeIndex:BreakLinksToAge(id) --So the index forgets about them
		else
			AgeIndex:DeleteAge(id)
		end
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad

	inst.OnRemoveEntity = OnRemove

	--Get a new animation!
	anim:SetBank("books")
	anim:SetBuild("books")
	anim:PlayAnimation("book_gardening")

	MakeInventoryPhysics(inst)
	
	inst:AddComponent("inspectable")
	inst.components.inspectable:SetDescription(function(inst, viewer)
		if inst:HasTag("linked") then
			return string.format(STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORLDBOOK.LINKED, STRINGS.MISC["LINK_"..string.upper(inst.components.worldbook.data.type)])
		else
			return string.format(STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORLDBOOK.GENERIC, STRINGS.MISC["LINK_"..string.upper(inst.components.worldbook.data.type)])
		end
	end)

	inst:AddComponent("book")
	inst.components.book.onread = UseFn

	inst:AddComponent("worldbook")

	inst:AddComponent("inkuser")
	inst.components.inkuser:SetQuota(TUNING.WORLDBOOK_COST)

	--Get a new texture!
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/worldbook.xml"
	inst.components.inventoryitem.imagename = "worldbook"

	inst:AddComponent("fuel")
	inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)

	return inst
end

return Prefab("common/worldbook", fn, Assets)