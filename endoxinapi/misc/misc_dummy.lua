--Any and all occurences of "dummy_" at the beginning of a prefab's name will be stripped upon spawning
local fn_spawnprefab = GLOBAL.SpawnPrefab
GLOBAL.SpawnPrefab = function(name)
	while name:sub(1,6) == "dummy_" do
		name = name:sub(7)
	end
	return fn_spawnprefab(name)
end