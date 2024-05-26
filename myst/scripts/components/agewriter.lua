local AgeWriter = Class(function(self, inst)
	self.inst = inst
	self.knownsymbols = {}
end)

function AgeWriter:LearnSymbol(symbol)
	self.knownsymbols[symbol] = true
end

function AgeWriter:ForgetSymbol(symbol)
	self.knownsymbols[symbol] = false
end

function AgeWriter:KnowsSymbol(symbol)
	if self.knownsymbols[symbol] then
		return true
	else
		return false
	end
end

function AgeWriter:GetKnownSymbols()
	local symbols = {}
	for k,v in pairs(self.knownsymbols) do
		if v then
			table.insert(symbols, k)
		end
	end
	return symbols
end

function AgeWriter:OnSave()
	local data = {}
	data.knownsymbols = self.knownsymbols or {}
	return data
end

function AgeWriter:OnLoad(data)
	if data.knownsymbols then
		self.knownsymbols = data.knownsymbols
	end
end

return AgeWriter