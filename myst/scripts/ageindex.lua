local AgeIndex = Class(function(self)
	self.ages = {}
	self.types = {}
	self.agenames = {}
	self.linkspots = {} --Descriptive book target locations
	self.markedfordeath = {}

	self.linkbooks = {} --The instances of the linking books (runtime only, world specific)
	self.links = {} --The target worlds of each linking book

	self:Load()
end)

function AgeIndex:DeleteSlot(slot)
	local oldslot = SaveGameIndex:GetCurrentSaveSlot()
	SaveGameIndex.current_slot = slot
	self.ages = nil
	self.types = nil
	self.agenames = nil
	self.linkspots = nil
	self.markedfordeath = nil
	self.links = nil
	self:OnSave()
	SaveGameIndex.current_slot = oldslot
	self:Load()
end

function AgeIndex:DeleteAge(id)
	EraseFiles(nil, {"age_"..id.."_"..SaveGameIndex:GetCurrentSaveSlot().."_"..SaveGameIndex:GetCurrentSaveSlot()})
	self.ages[id] = nil
	self.types[id] = nil
	self.agenames[id] = nil
	self.linkspots[id] = nil

	self:BreakLinksToAge(id)
	SaveGameIndex:SaveCurrent()
end

function AgeIndex:MarkAgeForDeath(id)
	table.insert(self.markedfordeath, id)
	for k,v in pairs(self.links) do
		if v == "age_"..id.."_"..SaveGameIndex:GetCurrentSaveSlot() then
			self.links[k] = false
		end
	end
end

function AgeIndex:BreakLinkBook(id)
	self.linkbooks[id].components.linkbook:Break()
	self.linkbooks[id] = nil
	self.links[id] = nil
end

function AgeIndex:BreakLinksToAge(id)
	for k,v in pairs(self.linkbooks) do
		if v.components.linkbook:GetTargetAge() == "age_"..id.."_"..SaveGameIndex:GetCurrentSaveSlot() then
			self:BreakLinkBook(k)
		end
	end
end

function AgeIndex:OnBookUse(book)
	if book.prefab == "worldbook" then
		self:OnDescriptiveBookUse(book)
	elseif book.prefab == "linkbook" then
		self:OnLinkingBookUse(book)
	end
end

function AgeIndex:OnDescriptiveBookUse(book)
	if not book:HasTag("linked") then
		local age = self:CompileBook(book)
		age = self:CompleteAge(age)
		self.ages[self:GetUID(book)] = age
		self.types[self:GetUID(book)] = book.components.worldbook.data.type
		self.agenames[self:GetUID(book)] = book.name
		book:AddTag("linked")
	end
	local id = self:GetUID(book)
	local x,y,z = self:GetLinkSpot(id)
	if self.linkspots[id] then
		x,y,z = unpack(self.linkspots[id])
	end
	self:LinkToAge("age_"..id.."_"..SaveGameIndex:GetCurrentSaveSlot(),x,y,z)
end

function AgeIndex:OnLinkingBookUse(book)
	self:LinkToAge(self:GetTarget(book))
end

function AgeIndex:LinkToAge(dim, x, y, z)
	SaveGameIndex:GoToDimension(dim, x, y, z)
end

function AgeIndex:SetLinkSpot(age, x, y, z)
	self.linkspots[age] = {x,y,z}
end

function AgeIndex:GetLinkSpot(age)
	return self.linkspots[age]
end

function AgeIndex:GetUID(book)
	return book.components.worldbook:GetUID()
end

function AgeIndex:IsAge(slot)
	return SaveGameIndex:GetCurrentMode(slot):sub(1,4) == "age_"
end

function AgeIndex:GetCurrentAge()
	if self:IsAge() then
		return tonumber(SaveGameIndex:GetCurrentMode():sub(5,5))
	end
end

function AgeIndex:GetCurrentAgeName()
	if self:IsAge() then
		return self.agenames[self:GetCurrentAge()]
	else
		local names = {
			["survival"] = STRINGS.MISC.LINKBOOK_SURVIVAL,
			["cave"] = STRINGS.MISC.LINK_CAVE,
			["shipwrecked"] = STRINGS.MISC.LINK_SHIPWRECKED
		}
		local name = names[SaveGameIndex:GetCurrentMode()]
		return name or STRINGS.MISC.UNKNOWN_LINK
	end
end

function AgeIndex:GetAgeType(age)
	local first_underscore = string.find(age,'_')
	local second_underscore
	if first_underscore then
		second_underscore = string.find(age,'_',first_underscore+1)
	end
	if second_underscore then
		local index = tonumber(string.sub(age,first_underscore+1,second_underscore-1))
		return (index and self.types[index]) or age
	else
		return age
	end
end

function AgeIndex:GetTarget(book)
	local x,y,z,d = book.components.linkbook:GetTarget()
	return d,x,y,z
end

function AgeIndex:GetNewWorldBookUID()
	local id = 1
	--[[for k,v in pairs(self) do
		print(k,v)
		if type(v) == type({}) then
			print("[")
			for kk,vv in pairs(v) do
				print(kk,vv)
			end
			print("]")
		end
	end]]
	for k,v in pairs(self.ages) do
		if v then
			id = id + 1
		else
			return k
		end
	end
	return id
end

function AgeIndex:GetNewLinkBookUID()
	local id = 1
	for k,v in pairs(self.links) do
		if v then
			id = id + 1
		else
			return k
		end
	end
	return id
end

function AgeIndex:RegisterLinkBook(inst)
	local id = inst.components.linkbook:GetUID()
	if self.links[id] == false then
		inst.components.linkbook:Break()
		self.links[id] = nil
		return
	end
	self.linkbooks[id] = inst
	self.links[id] = inst.components.linkbook:GetTargetAge()
end

function AgeIndex:CompileBook(book)
	local id = book.components.worldbook:GetUID()
	local name = book.name:sub(2,-2)
	local world_type = book.components.worldbook.data.type
	if world_type == "cave" then
		return MYST_WORLDGEN["CAVES_"..math.random(1,2)](id,name)
	else
		return MYST_WORLDGEN.FOREST(id,name)
	end
end

function AgeIndex:CompleteAge(age)
	return age
end

function AgeIndex:GetData()
	self.data = self.data or {}
	self.data.SLOTS = self.data.SLOTS or {}
	self.data.SLOTS[SaveGameIndex:GetCurrentSaveSlot()] = {
		AGES = self.ages,
		TYPES = self.types,
		AGENAMES = self.agenames,
		LINKSPOTS = self.linkspots,
		MARKEDFORDEATH = self.markedfordeath,
		LINKBOOKS = self.links
	}
	local data = self.data
	local datastring = DataDumper(data, nil, false)
	return datastring
end

function AgeIndex:OnSave()
	local file = "ageindex"
	local data = self:GetData()
	local cb = function()
		print("Successfully saved the Age Index")
	end
	print("Saving the Age Index")
	TheSim:SetPersistentString(file, data, false, cb)
end

function AgeIndex:Load(data)
	local file = "ageindex"
	print("Loading the Age Index") 
	TheSim:GetPersistentString(file, function(load_success, str)
		local success, savedata = RunInSandbox(str)
		if success and string.len(str) > 0 and savedata ~= nil then
			self.data = savedata
			local slotdata = self.data.SLOTS[SaveGameIndex:GetCurrentSaveSlot()] or {
				AGES = {},
				AGENAMES = {},
				LINKSPOTS = {},
				MARKEDFORDEATH = {}
			}
			self.ages = slotdata.AGES or {}
			self.types = slotdata.TYPES or {}
			self.agenames = slotdata.AGENAMES or {}
			self.linkspots = slotdata.LINKSPOTS or {}
			for k,v in pairs(slotdata.MARKEDFORDEATH or {}) do
				self:DeleteAge(v)
			end
			self.links = slotdata.LINKBOOKS or {}
			print("Loaded "..file)
			print("Successfully loaded the Age Index")
		else
			print("Could not load "..file)
		end
	end)
end

return AgeIndex