local function MakeGroundItem(name)
	local Assets = {
		Asset("ANIM", "anim/"..name.."_ground.zip"),

		Asset("ATLAS", "images/"..name.."_ground.xml"),
		Asset("IMAGE", "images/"..name.."_ground.tex")
	}

	local function fn()
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddAnimState()

		MakeInventoryPhysics(inst)

		inst.AnimState:SetBank(name.."_ground")
		inst.AnimState:SetBuild(name.."_ground")
		inst.AnimState:PlayAnimation("idle")

		inst:AddComponent("inspectable")

		inst:AddComponent("inventoryitem")
		inst.components.inventoryitem.atlasname = "images/"..name.."_ground.xml"
		inst.components.inventoryitem.imagename = name.."_ground"
		
		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

		inst:AddComponent("fuel")
		inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

		MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
		MakeSmallPropagator(inst)

		return inst
	end

	return Prefab("common/inventoryitems/"..name.."_ground", fn, Assets, {})
end

local ground_items = {
	"gumarabic",
	"pinecone"
}
local RoG = IsDLCInstalled(REIGN_OF_GIANTS)
local SW = IsDLCInstalled(CAPY_DLC) 
if RoG then
	table.insert(ground_items, "acorn")
end
if SW then
	table.insert(ground_items, "coconut")
end

local ret = {}
for _,v in ipairs(ground_items) do
	table.insert(ret, MakeGroundItem(v))
end

return unpack(ret)