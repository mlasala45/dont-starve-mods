local Drinkable = Class(function(self, inst)
	self.inst = inst
	self.quaff = false
	self.singleuse = true
end)

function Drinkable:SetOnDrinkFn(ondrinkfn)
	self.ondrinkfn = ondrinkfn
end

function Drinkable:CollectInventoryActions(doer, actions)
	local quaff = false
	if self.quaff then
		if type(self.quaff) == "function" then
			quaff = self.quaff(self.inst, doer)
		else
			quaff = self.quaff
		end 
	end
	if quaff then
		table.insert(actions, ACTIONS.QUAFF)
	else
		table.insert(actions, ACTIONS.DRINK)
	end
end

function Drinkable:Drink(doer)
	if self.ondrinkfn then
		self.ondrinkfn(self.inst, doer)
	end
	if self.singleuse then
		local item = self.inst
		if self.inst.components.stackable then
			item = self.inst.components.stackable:Get()
		end
		item:Remove()
	end
end

return Drinkable