GLOBAL.METEORSHOWERS = GetModConfigData("METEORSHOWERS")

local require = GLOBAL.require

require "meteors_tuning"
require "meteors_tuning_override"
require "meteors_constants"
require "meteors_strings"
require "meteors_recipes"

PrefabFiles = {
	"meteorspawner",
	"shadowmeteor",
	"meteorwarning",
	"burntground",
	"moonrocknugget",
	"rock_moon",
	"wall_moonrock"
}

AddComponentPostInit("health", function(self)
	self.playerabsorb = 0
	local function DoDelta(inst, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
		if inst.redirect ~= nil then
			inst.redirect(inst.inst, amount, overtime, cause)
			return
		end

		if not ignore_invincible and (inst.invincible or inst.inst.is_teleporting == true) then
			return
		end

		if amount < 0 and not ignore_absorb then
			amount = amount - amount * inst.absorb
			if afflicter ~= nil and afflicter:HasTag("player") then
				amount = amount - amount * inst.playerabsorb
			end
		end

		local old_percent = inst:GetPercent()
		inst:SetVal(inst.currenthealth + amount, cause, afflicter)
		local new_percent = inst:GetPercent()

		inst.inst:PushEvent("healthdelta", { oldpercent = old_percent, newpercent = inst:GetPercent(), overtime = overtime, cause = cause, afflicter = afflicter, amount = amount })

		if inst.ondelta ~= nil then
			inst.ondelta(inst.inst, old_percent, inst:GetPercent())
		end
	end
	self.DoDelta = DoDelta
end)

GLOBAL.c_meteor = function()
	GLOBAL.c_spawn("shadowmeteor")
end

GLOBAL.c_devastation = function(num, time)
	num = num or 5
	time = time or num/2
	for i=1,num do
		GLOBAL.GetPlayer():DoTaskInTime(time * (i / num), GLOBAL.c_meteor)
	end
end