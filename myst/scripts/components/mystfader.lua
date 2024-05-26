local MystFader = Class(function(self, inst)
	self.inst = inst
	self.visible = true
	self.timeleft = 0
	self.totaltime = 0
end)

function MystFader:Fade(visible, time, cb)
	self.visible = visible
	self.totaltime = time or 0
	if self.totaltime == 0 then
		self:DoFade(self.visible, self:GetPercent())
		if cb then
			cb(self.inst)
		end
	else
		self.timeleft = self.totaltime
		self.inst:StartUpdatingComponent(self)
		if cb then
			self.cb = cb
		end
	end
end

function MystFader:GetPercent()
	return 1 - (self.timeleft/self.totaltime)
end

function MystFader:DoFade(visible, percent)
	if not visible then percent = 1 - percent end
	self.inst.AnimState:SetMultColour(percent, percent, percent, percent)
end

function MystFader:OnUpdate(dt)
	self.timeleft = self.timeleft - dt
	if self.timeleft <= 0 then
		self.timeleft = 0
		self.inst:StopUpdatingComponent(self)
		if self.cb then
			self.cb(self.inst)
		end
	end
	self:DoFade(self.visible, self:GetPercent())
end

return MystFader