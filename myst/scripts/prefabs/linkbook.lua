local Assets = {
	Asset("ANIM", "anim/books.zip"),

	Asset("ATLAS", "images/linkbook.xml"),
	Asset("IMAGE", "images/linkbook.tex"),

	Asset("SOUNDPACKAGE", "sound/myst.fev"),
	Asset("SOUND", "sound/myst.fsb")
}

local function GetName(inst)
	return STRINGS.NAMES["LINKBOOK"].." "..STRINGS.MISC.LINKBOOK_CONJUNCTION.." "..AgeIndex:GetCurrentAgeName()
end

local function OnRemove(inst)
	if inst:HasTag("finalised") then
		local id = inst.components.linkbook:GetUID()
		AgeIndex:BreakLinkBook(id)
		local target = inst.components.linkbook:GetTargetAge()
		AgeIndex:VerifyAgeIntegrity(target)
	end
end

local function UseFn(inst, reader)
	if inst:HasTag("finalised") then
		if inst.components.linkbook:CanUse() then
			reader.sg:GoToState("still")
			reader.components.mystfader:Fade(false, 1, function()
				TheFrontEnd:Fade(false, 2, function() AgeIndex:OnBookUse(inst) end)
				inst.components.inventoryitem:GetContainer():DropItem(inst)
			end)
			inst.SoundEmitter:PlaySound("myst/common/link")
		else
			if inst.components.linkbook:IsBroken() then
				reader.components.talker:Say(GetString(reader.prefab, "ANNOUNCE_LINKBROKEN"))
			else
				reader.components.talker:Say(GetString(reader.prefab, "ANNOUNCE_BADDIM"))
			end
		end
	elseif reader.components.inventory then
		if inst.components.inkuser:UseInk(reader) then
			local x,y,z = reader.Transform:GetWorldPosition()
			local d = SaveGameIndex:GetCurrentMode(SaveGameIndex:GetCurrentSaveSlot())
			if d == "survival" then
				d = "forest"
			elseif d == "shipwrecked" then
				d = "tropics"
			end
			inst.components.linkbook:SetTarget(x,y,z,d)
			AgeIndex:RegisterLinkBook(inst)
			inst:AddTag("finalised")
			inst.components.named:SetName(GetName(inst))
		end
	end
	return true
end

local function OnSave(inst, data)
	data.finalised = inst:HasTag("finalised")
	data.name = inst.components.named.name
end

local function OnLoad(inst, data)
	if data then
		if data.finalised and data.name and not inst:HasTag("broken") then --Might have been broken by 'linkbook' component load already
			if data.broken then
				inst:AddTag("broken")
			else
				inst:AddTag("finalised")
			end
			inst.components.named:SetName(data.name)
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

	anim:SetBank("books")
	anim:SetBuild("books")
	anim:PlayAnimation("book_tentacles")

	MakeInventoryPhysics(inst)
	
	inst:AddComponent("inspectable")
	inst.components.inspectable:SetDescription(function(inst, viewer)
		if inst.components.linkbook:IsBroken() then
			return STRINGS.CHARACTERS.GENERIC.DESCRIBE.LINKBOOK.BROKEN
		else
			return STRINGS.CHARACTERS.GENERIC.DESCRIBE.LINKBOOK.GENERIC
		end
	end)

	inst:AddComponent("book")
	inst.components.book.onread = UseFn

	inst:AddComponent("linkbook")

	inst:AddComponent("inkuser")
	inst.components.inkuser:SetQuota(TUNING.LINKBOOK_COST)
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/linkbook.xml"
	inst.components.inventoryitem.imagename = "linkbook"

	inst:AddComponent("named")
	inst.components.named:SetName(STRINGS.PREFIXES.UNBOUND.." "..STRINGS.NAMES["LINKBOOK"])

	inst:AddComponent("fuel")
	inst.components.fuel.fuelvalue = TUNING.MED_FUEL

	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)

	return inst
end

return Prefab("common/linkbook", fn, Assets)