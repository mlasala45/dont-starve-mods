local InkUser = Class(function(self, inst)
	self.inst = inst
end)

function InkUser:SetQuota(amount)
	self.quota = amount
end

function InkUser:CanUse(inksource, amount)
	local quills = inksource.components.inventory:FindItems(function(item) return item.prefab == "quill" end)
	local totalink = 0
	for _,v in pairs(quills) do
		totalink = totalink + v.components.finiteuses:GetUses()
	end
	return totalink >= (amount or self.quota)
end

function InkUser:UseInk(inksource, amount, noannounce)
	if self:CanUse(inksource, amount) then
		local quills = inksource.components.inventory:FindItems(function(item) return item.prefab == "quill" end)
		local inkleft = (amount or self.quota)
		for _,v in pairs(quills) do
			if inkleft > v.components.finiteuses:GetUses() then
				inkleft = inkleft - v.components.finiteuses:GetUses()
				v.components.finiteuses:Use(v.components.finiteuses:GetUses())
			else
				v.components.finiteuses:Use(inkleft)
				break
			end
		end
		return true
	else
		if not noannounce and inksource.components.talker then
			inksource.components.talker:Say(GetString(inksource.prefab, "ANNOUNCE_NOINK"))
		end
		return false
	end
end

return InkUser