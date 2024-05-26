AddRoomPreInit("Rocky", function(room)
	room.contents.countprefabs = {
		meteorspawner = function() return math.random(1,2) end,
	}
end)