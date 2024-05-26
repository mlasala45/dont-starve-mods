modimport "endoxinapi_init.lua"

local EndoxinAPI = GLOBAL.EndoxinAPI

EndoxinAPI:Log("Initializing EndoxinAPI")

EndoxinAPI:LoadModule("misc")
EndoxinAPI:LoadModule("duplicaterecipes")
EndoxinAPI:LoadModule("recipetabs")
EndoxinAPI:LoadModule("specialingredients")
EndoxinAPI:LoadModule("techbranches")
EndoxinAPI:LoadModule("worlds")

EndoxinAPI:Log("Done initializing EndoxinAPI")