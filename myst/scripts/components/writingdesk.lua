local WritingDesk = Class(function(self, inst)
	self.inst = inst
end)

function WritingDesk:IsOpen()
	if self.open then
		return true
	else
		return false
	end
end

function WritingDesk:Open(doer)
	self.open = true
	if self.onopenfn then
		self.onopenfn(self.inst, doer)
	end
end

function WritingDesk:Close(doer)
	self.open = false
	if self.onclosefn then
		self.onclosefn(self.inst, doer)
	end
end

function WritingDesk:CollectSceneActions(doer, actions)
	if doer.components.inventory then
		table.insert(actions, ACTIONS.DESKRUMMAGE)
	end
end

return WritingDesk