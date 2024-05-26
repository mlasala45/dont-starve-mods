local WorldBook = Class(function(self)
	self.data = {}
	Copy(TEMPLATES.WORLDBOOK.__NEW,self.data)
end)

function WorldBook:GetUID()
	if not self.uid then
		self.uid = AgeIndex:GetNewWorldBookUID()
	end
	return self.uid
end

function WorldBook:OnSave()
	local data = {}
	data.uid = self.uid
	data.data = self.data
	return data
end

function WorldBook:OnLoad(data)
	if data then
		if data.uid then
			self.uid = data.uid
		end
		if data.data then
			self.data = data.data
		end
	end
end

return WorldBook