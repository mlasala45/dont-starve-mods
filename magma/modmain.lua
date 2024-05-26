local require = GLOBAL.require

require "magma_strings"

Assets = {
	Asset("IMAGE", "images/minimap/pond_lava.tex"),
	Asset("ATLAS", "images/minimap/pond_lava.xml")
}

PrefabFiles = {
	"lava_pond",
	"scorchedground",
	"scorched_skeleton",
	"burnt_marsh_bush"
}

AddMinimapAtlas("images/minimap/pond_lava.xml")

AddPrefabPostInit("marsh_bush", function(inst)
	inst.components.burnable:SetOnBurntFn(function(inst)
		local burnt = GLOBAL.SpawnPrefab("burnt_marsh_bush")
		burnt.Transform:SetPosition(inst.Transform:GetWorldPosition())
		inst:Remove()
	end)
end)