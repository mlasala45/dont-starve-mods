local LinkBook = Class(function(self, inst)
	self.inst = inst
end)

function LinkBook:SetTarget(x,y,z,d)
	self.x = x
	self.y = y
	self.z = z
	self.d = d
end

function LinkBook:GetUID()
	if not self.uid then
		self.uid = AgeIndex:GetNewLinkBookUID()
	end
	return self.uid
end

function LinkBook:GetTarget()
	return self.x, self.y, self.z, self.d
end

function LinkBook:GetTargetAge()
	return self.d
end

function LinkBook:CanUse()
	local dim = SaveGameIndex:GetCurrentMode(SaveGameIndex:GetCurrentSaveSlot())
	if dim == "survival" then
		dim = "forest"
	elseif dim == "shipwrecked" then
		dim = "tropics"
	end
	return self.d ~= dim and not self.broken
end

function LinkBook:Break()
	self.broken = true
	self.inst:AddTag("broken")
	self.inst.components.named:SetName(STRINGS.PREFIXES.BROKEN.." "..self.inst.components.named.name)
end

function LinkBook:IsBroken()
	return self.broken == true
end

function LinkBook:OnSave()
	local data = {}
	if self.broken then
		data.broken = true
	else
		if self.x then
			data.x = self.x
		end
		if self.y then
			data.y = self.y
		end
		if self.z then
			data.z = self.z
		end
		if self.d then
			data.d = self.d
		end
		if self.uid then
			data.uid = self.uid
		end
	end
	return data
end

function LinkBook:OnLoad(data)
	if data then
		if data.broken then
			self.broken = true
			self.inst:AddTag("broken")
		else
			if data.x then
				self.x = data.x
			end
			if data.y then
				self.y = data.y
			end
			if data.z then
				self.z = data.z
			end
			if data.d then
				self.d = data.d
			end
			if data.uid then
				self.uid = data.uid
				AgeIndex:RegisterLinkBook(self.inst)
			end
		end
	end
end

return LinkBook