local HandheldContainer = Class(function(self, inst)
	self.inst = inst
end)

function HandheldContainer:CollectInventoryActions(doer, actions)
	table.insert(actions, ACTIONS.RUMMAGE)
end

return HandheldContainer