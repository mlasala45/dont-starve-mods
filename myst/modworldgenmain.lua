local require = GLOBAL.require

require "map/tasks"

AddTask("Nothing", {
	locks=GLOBAL.LOCKS.NONE,
	keys_given=GLOBAL.KEYS.NONE,
	room_choices={
		["Nothing"] = 1
	},
	room_bg=GLOBAL.GROUND.IMPASSABLE,
	background_room="Nothing",
	colour={r=0,g=0,b=0,a=1}
})

local patched = false
local json = GLOBAL.require("json")
local decode = json.decode
json.decode = function(...)
	if GLOBAL.rawget(GLOBAL, "GenerateNew") and not patched then
		local fn = GLOBAL.GenerateNew
		GLOBAL.GenerateNew = function(debug, params)
			if params.AGES then
				for k,v in pairs(params.AGES) do
					print("Registering slot "..k.." dimensions")
					for kk,vv in pairs(v) do
						print("Registering age "..kk)
						GLOBAL.RegisterDimension("age_"..kk.."_"..k, vv)
					end
				end
			end
			return fn(debug, params)
		end
		patched = true
	end
	return decode(...)
end