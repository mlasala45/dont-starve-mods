local TeleportOnLoad = Class(function(self, inst)
	self.inst = inst
end)

function TeleportOnLoad:SetTarget(x, y, z)
	if x then
		self.x = x
	end
	if y then
		self.y = y
	end
	if z then
		self.z = z
	end
end

function TeleportOnLoad:ClearTarget(notx, noty, notz)
	if not notx then
		self.x = nil
	end
	if not noty then
		self.y = nil
	end
	if not notz then
		self.z = nil
	end
end

function TeleportOnLoad:OnSave()
	local data = {}
	if self.x then
		data.x = self.x
	end
	if self.y then
		data.y = self.y
	end
	if self.z then
		data.z = self.z
	end
	return data
end

function TeleportOnLoad:OnLoad(data)
	if data then
		if data.x then
			self.x = data.x
		end
		if data.y then
			self.y = data.y
		end
		if data.z then
			self.z = data.z
		end
	end
	if self.inst.Transform and (self.x or self.y or self.z) then
		local x,y,z = self.inst.Transform:GetWorldPosition()
		if not self.x then
			self.x = x
		end
		if not self.y then
			self.y = y
		end
		if not self.z then
			self.z = z
		end
		self.inst.Transform:SetPosition(self.x, self.y, self.z)
		self:ClearTarget()
	end
end

return TeleportOnLoad