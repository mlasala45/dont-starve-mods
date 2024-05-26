local function load(module)
	modimport("misc/misc_"..module..".lua")
end

load("drinking") --Adds functionality for making items drinkable (or quaffable!)
load("dummy") --Makes all prefabs of the form "dummy_*" spawn as "*"
load("proxy") --Means to call functions upon assignment and retrieval of values in a table
load("util") --Useful things!