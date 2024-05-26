--Creates a proxy that intercepts all data flow involving 't', calling the two functions when data is fetched and set, respectively
function GLOBAL.SetProxy(target, index, newindex)
	local mt = {}
	GLOBAL.setmetatable(target, mt)

	local proxy = {}

	mt.__newindex = function(t,k,v)
		newindex(proxy,k,v)
	end

	mt.__index = function(t,k)
		return index(proxy,k)
	end

	mt.__proxy = proxy
end

--Adjusts 'pairs' and 'ipairs' to recognize the '__proxy' metafield
local fn_pairs = GLOBAL.pairs
GLOBAL.pairs = function(t)
	if GLOBAL.getmetatable(t) and GLOBAL.getmetatable(t).__proxy then
		return fn_pairs(GLOBAL.getmetatable(t).__proxy)
	else
		return fn_pairs(t)
	end
end
local fn_ipairs = GLOBAL.ipairs
GLOBAL.ipairs = function(t)
	if GLOBAL.getmetatable(t) and GLOBAL.getmetatable(t).__proxy then
		return fn_ipairs(GLOBAL.getmetatable(t).__proxy)
	else
		return fn_ipairs(t)
	end
end