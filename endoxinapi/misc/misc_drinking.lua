--This won't work if Shipwrecked isn't on
if GLOBAL.IsDLCEnabled(GLOBAL.CAPY_DLC) then
	GLOBAL.STRINGS.ACTIONS.DRINK = "Drink"
	GLOBAL.STRINGS.ACTIONS.QUAFF = "Quaff"

	local action_drink = GLOBAL.Action()
	action_drink.str = GLOBAL.STRINGS.ACTIONS.DRINK
	action_drink.id = "DRINK"
	action_drink.fn = function(act)
		if act.invobject and act.invobject.components.drinkable then
			act.invobject.components.drinkable:Drink(act.doer)
		end
	end

	local action_quaff = GLOBAL.Action()
	action_quaff.str = GLOBAL.STRINGS.ACTIONS.QUAFF
	action_quaff.id = "QUAFF"
	action_quaff.fn = function(act)
		if act.invobject and act.invobject.components.drinkable then
			act.invobject.components.drinkable:Drink(act.doer)
		end
	end

	AddAction(action_drink)
	AddAction(action_quaff)
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(action_drink, "curepoison"))
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(action_quaff, "curepoison"))
end