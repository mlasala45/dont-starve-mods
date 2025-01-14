local Builder = Class(function(self, inst)
	self.inst = inst
	self.recipes = {}
	self.recipe_count = 0
	self.accessible_tech_trees = TECH.NONE
	self.inst:StartUpdatingComponent(self)
	self.current_prototyper = nil
	self.buffered_builds = {}
	self.bonus_tech_level = 0
	self.science_bonus = 0
	self.magic_bonus = 0
	self.ancient_bonus = 0
	self.obsidian_bonus = 0
	self.custom_tabs = {}
	self.ingredientmod = 1
	self.jellybrainhat = false
	
end)

function Builder:ActivateCurrentResearchMachine()
	if self.current_prototyper and self.current_prototyper.components.prototyper then
		self.current_prototyper.components.prototyper:Activate()
	end
end

function Builder:AddRecipeTab(tab)
	table.insert(self.custom_tabs, tab)
end

function Builder:OnSave()
	local data =
	{
		buffered_builds = self.buffered_builds
	}
	
	data.recipes = self.recipes

	return data
end

function Builder:OnLoad(data)
	
	
	if data.buffered_builds then
		self.buffered_builds = data.buffered_builds
	end
	
	if data.recipes then
		for k,v in pairs(data.recipes) do
			self:AddRecipe(v)
		end
	end
end

function Builder:IsBuildBuffered(recipe)
	return self.buffered_builds[recipe] ~= nil
end

function Builder:BufferBuild(recipe)
	local mats = self:GetIngredients(recipe)
	local wetLevel = self:GetIngredientWetness(mats)	
	self:RemoveIngredients(mats)
	self.buffered_builds[recipe] = {}
	self.buffered_builds[recipe].wetLevel = wetLevel
	self.inst:PushEvent("bufferbuild", {recipe = GetRecipe(recipe)})
end

function Builder:OnUpdate(dt)
	self:EvaluateTechTrees()
end

function Builder:GiveAllRecipes()
	if self.freebuildmode then
		self.freebuildmode = false
	else
		self.freebuildmode = true
	end
	self.inst:PushEvent("unlockrecipe")
end

function Builder:UnlockRecipesForTech(tech)
	local propertech = function(recipetree, buildertree)
		for k,v in pairs(recipetree) do
			if buildertree[tostring(k)] and recipetree[tostring(k)] and
			recipetree[tostring(k)] > buildertree[tostring(k)] then
					return false
			end
		end
		return true
	end

	local recipes = GetAllRecipes()
	for k,v in pairs(recipes) do
		if propertech(v.level, tech) then
			self:UnlockRecipe(v.name)
		end
	end
end

function Builder:CanBuildAtPoint(pt, recipe)

	local ground = GetWorld()
	local tile = GROUND.GRASS
	if ground and ground.Map then
		tile = ground.Map:GetTileAtPoint(pt:Get())
	end

	local onWater = ground.Map:IsWater(tile)
	local boating = self.inst.components.driver and self.inst.components.driver.driving

	local x, y, z = pt:Get()
	if(recipe.aquatic)  then --This thing needs to be built in water 
		
		if boating then 
			local minBuffer = 2
			local testTile = ground.Map:GetTileAtPoint(x + minBuffer, y, z)
			onWater = ground.Map:IsWater(testTile) and onWater
			testTile = ground.Map:GetTileAtPoint(x - minBuffer, y, z)
			onWater = ground.Map:IsWater(testTile) and onWater
			testTile = ground.Map:GetTileAtPoint(x , y, z + minBuffer)
			onWater = ground.Map:IsWater(testTile) and onWater
			testTile = ground.Map:GetTileAtPoint(x , y, z - minBuffer)
			onWater = ground.Map:IsWater(testTile) and onWater
			return onWater
		else 
   
			local testTile = self.inst:GetCurrentTileType(x, y, z)--ground.Map:GetTileAtPoint(x , y, z)
			local isShore = ground.Map:IsShore(testTile) --testTile == GROUND.OCEAN_SHORE --ground.Map:IsWater(testTile)
			--[[
			testTile = self.inst:GetCurrentTileType(x + buffer, y, z)--ground.Map:GetTileAtPoint(x , y, z)
			isShore = isShore and testTile == GROUND.OCEAN_SHORE --ground.Map:IsWater(testTile)
			testTile = self.inst:GetCurrentTileType(x - buffer, y, z)--ground.Map:GetTileAtPoint(x , y, z)
			isShore = isShore and testTile == GROUND.OCEAN_SHORE --ground.Map:IsWater(testTile)
			testTile = self.inst:GetCurrentTileType(x, y, z+ buffer)--ground.Map:GetTileAtPoint(x , y, z)
			isShore = isShore and testTile == GROUND.OCEAN_SHORE --ground.Map:IsWater(testTile)
			testTile = self.inst:GetCurrentTileType(x, y, z - buffer)--ground.Map:GetTileAtPoint(x , y, z)
			isShore = isShore and testTile == GROUND.OCEAN_SHORE --ground.Map:IsWater(testTile)
			return isShore
			]]
			local maxBuffer = 2
			local nearShore = false 
			testTile = self.inst:GetCurrentTileType(x + maxBuffer, y, z)
			nearShore = (not ground.Map:IsWater(testTile)) or nearShore
			testTile = self.inst:GetCurrentTileType(x - maxBuffer, y, z)
			nearShore = (not ground.Map:IsWater(testTile)) or nearShore
			testTile = self.inst:GetCurrentTileType(x , y, z + maxBuffer)
			nearShore = (not ground.Map:IsWater(testTile)) or nearShore
			testTile = self.inst:GetCurrentTileType(x , y, z - maxBuffer)
			nearShore = (not ground.Map:IsWater(testTile)) or nearShore

			testTile = self.inst:GetCurrentTileType(x + maxBuffer, y, z + maxBuffer)
			nearShore = (not ground.Map:IsWater(testTile)) or nearShore
			testTile = self.inst:GetCurrentTileType(x - maxBuffer, y, z + maxBuffer)
			nearShore = (not ground.Map:IsWater(testTile)) or nearShore
			testTile = self.inst:GetCurrentTileType(x + maxBuffer , y, z - maxBuffer)
			nearShore = (not ground.Map:IsWater(testTile)) or nearShore
			testTile = self.inst:GetCurrentTileType(x - maxBuffer , y, z - maxBuffer)
			nearShore = (not ground.Map:IsWater(testTile)) or nearShore

			local minBuffer = 0.5
			local tooClose = false 
			testTile = self.inst:GetCurrentTileType(x + minBuffer, y, z)
			tooClose = (not ground.Map:IsWater(testTile)) or tooClose
			testTile = self.inst:GetCurrentTileType(x - minBuffer, y, z)
			tooClose = (not ground.Map:IsWater(testTile)) or tooClose
			testTile = self.inst:GetCurrentTileType(x , y, z + minBuffer)
			tooClose = (not ground.Map:IsWater(testTile)) or tooClose
			testTile = self.inst:GetCurrentTileType(x , y, z - minBuffer)
			tooClose = (not ground.Map:IsWater(testTile)) or tooClose

			testTile = self.inst:GetCurrentTileType(x + minBuffer, y, z + minBuffer)
			tooClose = (not ground.Map:IsWater(testTile)) or tooClose
			testTile = self.inst:GetCurrentTileType(x - minBuffer, y, z + minBuffer)
			tooClose = (not ground.Map:IsWater(testTile)) or tooClose
			testTile = self.inst:GetCurrentTileType(x + minBuffer , y, z - minBuffer)
			tooClose = (not ground.Map:IsWater(testTile)) or tooClose
			testTile = self.inst:GetCurrentTileType(x - minBuffer, y, z - minBuffer)
			tooClose = (not ground.Map:IsWater(testTile)) or tooClose

			return isShore and nearShore and not tooClose

		end 


		--return (boating and ) or testTile == GROUND.OCEAN_SHORE
	end 

		--[[
		local x, y, z = pt:Get()
		local minBuffer = 2
		--Make sure this position is also surounded by water on each side by the distance of buffer 
		
		local testTile = ground.Map:GetTileAtPoint(x + minBuffer, y, z)
		onWater = ground.Map:IsWater(testTile) and onWater
		testTile = ground.Map:GetTileAtPoint(x - minBuffer, y, z)
		onWater = ground.Map:IsWater(testTile) and onWater
		testTile = ground.Map:GetTileAtPoint(x , y, z + minBuffer)
		onWater = ground.Map:IsWater(testTile) and onWater
		testTile = ground.Map:GetTileAtPoint(x , y, z - minBuffer)
		onWater = ground.Map:IsWater(testTile) and onWater

		if(not boating) then --If we're not in the boat make sure the build point is close to shore 
			local maxBuffer = 5
			local nearShore = false 
			testTile = ground.Map:GetTileAtPoint(x + maxBuffer, y, z)
			nearShore = (not ground.Map:IsWater(testTile)) or nearShore
			testTile = ground.Map:GetTileAtPoint(x - maxBuffer, y, z)
			nearShore = (not ground.Map:IsWater(testTile)) or nearShore
			testTile = ground.Map:GetTileAtPoint(x , y, z + maxBuffer)
			nearShore = (not ground.Map:IsWater(testTile)) or nearShore
			testTile = ground.Map:GetTileAtPoint(x , y, z - maxBuffer)
			nearShore = (not ground.Map:IsWater(testTile)) or nearShore

			if not nearShore then 
				return false 
			end 
		end 
	
		if not onWater then 
			return false 
		end
	elseif onWater then 
		return false 
	end 
	]]


	if tile == GROUND.IMPASSABLE or (boating and not recipe.aquatic) then
		return false
	else
		local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 6, nil, {'player', 'fx', 'NOBLOCK'}) -- or we could include a flag to the search?
		for k, v in pairs(ents) do
			if v ~= self.inst and (not v.components.placer) and v.entity:IsVisible() and not (v.components.inventoryitem and v.components.inventoryitem.owner ) then
				local min_rad = recipe.min_spacing or 2+1.2
				--local rad = (v.Physics and v.Physics:GetRadius() or 1) + 1.25
				
				--stupid finalling hack because it's too late to change stuff
				if recipe.name == "treasurechest" and v.prefab == "pond" then
					min_rad = min_rad + 1
				end

				local dsq = distsq(Vector3(v.Transform:GetWorldPosition()), pt)
				if dsq <= min_rad*min_rad then
					return false
				end
			end
		end
	end
	
	return true
end

if IsDLCEnabled(CAPY_DLC) or IsDLCEnabled(REIGN_OF_GIANTS) then
	function Builder:EvaluateTechTrees()
		local pos = self.inst:GetPosition()
		local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.RESEARCH_MACHINE_DIST, {"prototyper"})

		local old_accessible_tech_trees = deepcopy(self.accessible_tech_trees or TECH.NONE)
		local old_prototyper = self.current_prototyper
		self.current_prototyper = nil

		local prototyper_active = false
		for k,v in pairs(ents) do
			if v.components.prototyper then
				if not prototyper_active and not v.components.prototyper:GetIsDisabled() then
					--activate the first machine in the list. This will be the one you're closest to.
					v.components.prototyper:TurnOn()
					self.accessible_tech_trees = v.components.prototyper:GetTechTrees()
					prototyper_active = true
					self.current_prototyper = v
				else
					--you've already activated a machine. Turn all the other machines off.
					v.components.prototyper:TurnOff()
				end
			end
		end

		--add any character specific bonuses to your current tech levels.
		if not prototyper_active  then
			self.accessible_tech_trees.SCIENCE = self.science_bonus
			self.accessible_tech_trees.MAGIC = self.magic_bonus
			self.accessible_tech_trees.ANCIENT = self.ancient_bonus
			self.accessible_tech_trees.OBSIDIAN = self.obsidian_bonus
		else
			self.accessible_tech_trees.SCIENCE = self.accessible_tech_trees.SCIENCE + self.science_bonus
			self.accessible_tech_trees.MAGIC = self.accessible_tech_trees.MAGIC + self.magic_bonus
			self.accessible_tech_trees.ANCIENT = self.accessible_tech_trees.ANCIENT + self.ancient_bonus
			self.accessible_tech_trees.OBSIDIAN = (self.accessible_tech_trees.OBSIDIAN or 0) + self.obsidian_bonus
		end
		local trees_changed = false
		
		for k,v in pairs(old_accessible_tech_trees) do
			if v ~= self.accessible_tech_trees[k] then 
				trees_changed = true
				break
			end
		end
		if not trees_changed then
			for k,v in pairs(self.accessible_tech_trees) do
				if v ~= old_accessible_tech_trees[k] then 
					trees_changed = true
					break
				end
			end
		end

		if old_prototyper and old_prototyper.components.prototyper and old_prototyper:IsValid() and old_prototyper ~= self.current_prototyper then
			old_prototyper.components.prototyper:TurnOff()
		end

		if trees_changed then
			self.inst:PushEvent("techtreechange", {level = self.accessible_tech_trees})
		end
	end
else
	function Builder:EvaluateTechTrees()
		local pos = self.inst:GetPosition()
		local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.RESEARCH_MACHINE_DIST, {"prototyper"})

		local old_accessible_tech_trees = deepcopy(self.accessible_tech_trees or TECH.NONE)
		local old_prototyper = self.current_prototyper
		self.current_prototyper = nil

		local prototyper_active = false
		for k,v in pairs(ents) do
			if v.components.prototyper then
				if not prototyper_active then
					--activate the first machine in the list. This will be the one you're closest to.
					v.components.prototyper:TurnOn()
					self.accessible_tech_trees = v.components.prototyper:GetTechTrees()
					prototyper_active = true
					self.current_prototyper = v
				else
					--you've already activated a machine. Turn all the other machines off.
					v.components.prototyper:TurnOff()
				end
			end
		end

		--add any character specific bonuses to your current tech levels.
		if not prototyper_active  then
			self.accessible_tech_trees.SCIENCE = self.science_bonus
			self.accessible_tech_trees.MAGIC = self.magic_bonus
			self.accessible_tech_trees.ANCIENT = self.ancient_bonus
		else
			self.accessible_tech_trees.SCIENCE = self.accessible_tech_trees.SCIENCE + self.science_bonus
			self.accessible_tech_trees.MAGIC = self.accessible_tech_trees.MAGIC + self.magic_bonus
			self.accessible_tech_trees.ANCIENT = self.accessible_tech_trees.ANCIENT + self.ancient_bonus
		end

		local trees_changed = false
		
		for k,v in pairs(old_accessible_tech_trees) do
			if v ~= self.accessible_tech_trees[k] then 
				trees_changed = true
				break
			end
		end
		if not trees_changed then
			for k,v in pairs(self.accessible_tech_trees) do
				if v ~= old_accessible_tech_trees[k] then 
					trees_changed = true
					break
				end
			end
		end

		if old_prototyper and old_prototyper.components.prototyper and old_prototyper:IsValid() and old_prototyper ~= self.current_prototyper then
			old_prototyper.components.prototyper:TurnOff()
		end

		if trees_changed then
			self.inst:PushEvent("techtreechange", {level = self.accessible_tech_trees})
		end
	end
end


function Builder:AddRecipe(rec)
	if table.contains(self.recipes, rec) == false then
		table.insert(self.recipes, rec)
		self.recipe_count = self.recipe_count + 1
	end
end

function Builder:UnlockRecipe(recname)
	local recipe = GetRecipe(recname)

	if not recipe.nounlock and not self.brainjellyhat then
	--print("Unlocking: ", recname)
		if self.inst.components.sanity then
			self.inst.components.sanity:DoDelta(TUNING.SANITY_MED)
		end
		
		self:AddRecipe(recname)
		self.inst:PushEvent("unlockrecipe", {recipe = recname})
	end
end

--Edited
function Builder:GetIngredientWetness(ingredients)
	local wetness = {}
	for item, ents in pairs(ingredients) do
		if type(ents) == "table" then
			for k,v in pairs(ents) do
				if k.components.moisturelistener then
					table.insert(wetness, {wetness = k.components.moisturelistener.moisture, num = v})
				else
					table.insert(wetness, {wetness = 0, num = v})
				end
			end
		end
	end

	local totalWetness = 0
	local totalItems = 0
	for k,v in pairs(wetness) do
		totalWetness = totalWetness + (v.wetness * v.num)
		totalItems = totalItems + v.num
	end
	if totalItems < 1 then totalItems = 1 end

	return totalWetness/totalItems
end

local function GetIngredient(self,v)
	local amt = math.max(1, RoundUp(v.amount * self.ingredientmod))
	if v.ingtype == "SPECIAL" then
		return v.usefn, amt
	else
		local items = self.inst.components.inventory:GetItemByName(v.type, amt)
		if GetLength(items)>0 then
			return v.type, items
		end
	end
	return nil
end

--Edited
function Builder:GetIngredients(recname)
	local recipe = GetRecipe(recname)
	if recipe then
		local ingredients = {}
		for k,v in pairs(recipe.ingredients) do
			if v.ingtype == "VARIABLE" then
				local presentIngredients = {}
				for ik,iv in pairs(v.ingredients) do
					local item,ents = GetIngredient(self,iv)
					if item then
						table.insert(presentIngredients,{item,ents})
					end
				end
				local ing = presentIngredients[math.random(1,#presentIngredients)]
				local item,ents = ing[1],ing[2]
				ingredients[item] = ents
			else
				local item,ents = GetIngredient(self,v)
				ingredients[item] = ents
			end
		end
		return ingredients
	end
end

local function RemoveIngredients(self,ingredients)
	for item, ents in pairs(ingredients) do
		if type(item) == "function" then
			item(self.inst,ents) --I should probably rename the vars
		else
			for k,v in pairs(ents) do
				for i = 1, v do
					self.inst.components.inventory:RemoveItem(k, false):Remove()
				end
			end
		end
	end
	self.inst:PushEvent("consumeingredients")
end

--Edited
if IsDLCEnabled(CAPY_DLC) or IsDLCEnabled(REIGN_OF_GIANTS) then
	function Builder:RemoveIngredients(ingredients)
		RemoveIngredients(self,ingredients)
	end
else
	function Builder:RemoveIngredients(recname)
		RemoveIngredients(self,self:GetIngredients(recname))
	end
end

function Builder:OnSetProfile(profile)
end

function Builder:MakeRecipe(recipe, pt, rot, onsuccess)
	if recipe then
		self.inst:PushEvent("makerecipe", {recipe = recipe})
		pt = pt or Point(self.inst.Transform:GetWorldPosition())
		if self:IsBuildBuffered(recipe.name) or self:CanBuild(recipe.name) then
			self.inst.components.locomotor:Stop()
			local buffaction = BufferedAction(self.inst, nil, ACTIONS.BUILD, nil, pt, recipe.name, recipe.distance or 1, rot)
			if onsuccess then
				buffaction:AddSuccessAction(onsuccess)
			end
			
			self.inst.components.locomotor:PushAction(buffaction, true)
			
			return true
		end
	end
	return false
end

if IsDLCEnabled(CAPY_DLC) or IsDLCEnabled(REIGN_OF_GIANTS) then
	function Builder:DoBuild(recname, pt, rotation)
		local recipe = GetRecipe(recname)
		local buffered = self:IsBuildBuffered(recname)

		if recipe and self:IsBuildBuffered(recname) or self:CanBuild(recname) then
			
			local wetLevel = 0
			if self.buffered_builds[recname] then
				wetLevel = self.buffered_builds[recname].wetLevel
				self.buffered_builds[recname] = nil
			else
				local mats = self:GetIngredients(recname)
				wetLevel = self:GetIngredientWetness(mats) or 0
				self:RemoveIngredients(mats)
			end
			
			local prod = SpawnPrefab(recipe.product)
			if prod then

				if prod and prod.components.moisturelistener and wetLevel then
					prod.components.moisturelistener.moisture = wetLevel
					prod.components.moisturelistener:DoUpdate()
				end

				if prod.components.inventoryitem then
					if self.inst.components.inventory then
						 
						--self.inst.components.inventory:GiveItem(prod)
						self.inst:PushEvent("builditem", {item=prod, recipe = recipe})
						ProfileStatsAdd("build_"..prod.prefab)


						if prod.components.equippable and prod.components.equippable.equipslot and not self.inst.components.inventory:GetEquippedItem(prod.components.equippable.equipslot) then
							--The item is equippable. Equip it.
							self.inst.components.inventory:Equip(prod)

							if recipe.numtogive > 1 then
								--Looks like the recipe gave more than one item! Spawn in the rest and give them to the player.
								for i = 2, recipe.numtogive do
									local addt_prod = SpawnPrefab(recipe.product)
									self.inst.components.inventory:GiveItem(addt_prod, nil, TheInput:GetScreenPosition())
								end
							end
						else
							--Should this item just go into a boat equip slot? 
							local givenToVehicle = false 
							if prod.components.equippable and prod.components.equippable.boatequipslot and self.inst.components.driver and  self.inst.components.driver.vehicle then 
								local vehicle = self.inst.components.driver.vehicle
								if vehicle.components.container.hasboatequipslots and not vehicle.components.container:GetItemInBoatSlot(prod.components.equippable.boatequipslot) then 
									vehicle.components.container:Equip(prod)
									givenToVehicle = true 
									if recipe.numtogive > 1 then
										--Looks like the recipe gave more than one item! Spawn in the rest and give them to the player.
										for i = 2, recipe.numtogive do
											local addt_prod = SpawnPrefab(recipe.product)
											self.inst.components.inventory:GiveItem(addt_prod, nil, TheInput:GetScreenPosition())
										end
									end
								end 
							end  
							if not givenToVehicle then 
								if recipe.numtogive > 1 and prod.components.stackable then
									--The item is stackable. Just increase the stack size of the original item.
									prod.components.stackable:SetStackSize(recipe.numtogive)
									self.inst.components.inventory:GiveItem(prod, nil, TheInput:GetScreenPosition())
								elseif recipe.numtogive > 1 and not prod.components.stackable then
									--We still need to give the player the original product that was spawned, so do that.
									self.inst.components.inventory:GiveItem(prod, nil, TheInput:GetScreenPosition())
									--Now spawn in the rest of the items and give them to the player.
									for i = 2, recipe.numtogive do
										local addt_prod = SpawnPrefab(recipe.product)
										self.inst.components.inventory:GiveItem(addt_prod, nil, TheInput:GetScreenPosition())
									end
								else
									--Only the original item is being received.
									self.inst.components.inventory:GiveItem(prod, nil, TheInput:GetScreenPosition())
								end
							end 
						end

						if self.onBuild then
							self.onBuild(self.inst, prod)
						end	
						prod:OnBuilt(self.inst)
						
						return true
					end
				else
					pt = pt or Point(self.inst.Transform:GetWorldPosition())
					prod.Transform:SetPosition(pt.x,pt.y,pt.z)
					prod.Transform:SetRotation(rotation or 0)
					self.inst:PushEvent("buildstructure", {item=prod, recipe = recipe})
					prod:PushEvent("onbuilt")
					ProfileStatsAdd("build_"..prod.prefab)
					
					if self.onBuild then
						self.onBuild(self.inst, prod)
					end
					
					prod:OnBuilt(self.inst)

					if buffered then GetPlayer().HUD.controls.crafttabs:UpdateRecipes() end
									
					return true
				end

			end
		end
	end
else
	function Builder:DoBuild(recname, pt)
		local recipe = GetRecipe(recname)
		local buffered = self:IsBuildBuffered(recname)

		if recipe and self:IsBuildBuffered(recname) or self:CanBuild(recname) then

			if self.buffered_builds[recname] then
				self.buffered_builds[recname] = nil
			else
				self:RemoveIngredients(recname)
			end
			
			local prod = SpawnPrefab(recipe.product)
			if prod then
				if prod.components.inventoryitem then
					if self.inst.components.inventory then
						 
						--self.inst.components.inventory:GiveItem(prod)
						self.inst:PushEvent("builditem", {item=prod, recipe = recipe})
						ProfileStatsAdd("build_"..prod.prefab)


						if prod.components.equippable and not self.inst.components.inventory:GetEquippedItem(prod.components.equippable.equipslot) then
							--The item is equippable. Equip it.
							self.inst.components.inventory:Equip(prod)

							if recipe.numtogive > 1 then
								--Looks like the recipe gave more than one item! Spawn in the rest and give them to the player.
								for i = 2, recipe.numtogive do
									local addt_prod = SpawnPrefab(recipe.product)
									self.inst.components.inventory:GiveItem(addt_prod, nil, TheInput:GetScreenPosition())
								end
							end

						else

							if recipe.numtogive > 1 and prod.components.stackable then
								--The item is stackable. Just increase the stack size of the original item.
								prod.components.stackable:SetStackSize(recipe.numtogive)
								self.inst.components.inventory:GiveItem(prod, nil, TheInput:GetScreenPosition())
							elseif recipe.numtogive > 1 and not prod.components.stackable then
								--We still need to give the player the original product that was spawned, so do that.
								self.inst.components.inventory:GiveItem(prod, nil, TheInput:GetScreenPosition())
								--Now spawn in the rest of the items and give them to the player.
								for i = 2, recipe.numtogive do
									local addt_prod = SpawnPrefab(recipe.product)
									self.inst.components.inventory:GiveItem(addt_prod, nil, TheInput:GetScreenPosition())
								end
							else
								--Only the original item is being received.
								self.inst.components.inventory:GiveItem(prod, nil, TheInput:GetScreenPosition())
							end
						end

						if self.onBuild then
							self.onBuild(self.inst, prod)
						end	
						prod:OnBuilt(self.inst)
						
						return true
					end
				else

					pt = pt or Point(self.inst.Transform:GetWorldPosition())
					prod.Transform:SetPosition(pt.x,pt.y,pt.z)
					self.inst:PushEvent("buildstructure", {item=prod, recipe = recipe})
					prod:PushEvent("onbuilt")
					ProfileStatsAdd("build_"..prod.prefab)
					
					if self.onBuild then
						self.onBuild(self.inst, prod)
					end
					
					prod:OnBuilt(self.inst)

					if buffered then GetPlayer().HUD.controls.crafttabs:UpdateRecipes() end
									
					return true
				end
			end
		end
	end
end

function Builder:KnowsRecipe(recname)
	local recipe = GetRecipe(recname)

	if recipe and recipe.level.ANCIENT <= self.ancient_bonus and recipe.level.MAGIC <= self.magic_bonus and recipe.level.SCIENCE <= self.science_bonus and recipe.level.OBSIDIAN <= self.obsidian_bonus then
		return true
	end

	return self.freebuildmode or self.jellybrainhat or table.contains(self.recipes, recname)
end

local function CheckIngredient(self,ing)
	local amt = math.max(1, RoundUp(ing.amount * self.ingredientmod))
	if ing.ingtype == "SPECIAL" then
		if ing.amtfn(self.inst) < amt then
			return false
		end
	else
		if not self.inst.components.inventory:Has(ing.type, amt) then
			return false
		end
	end
	return true
end

--Edited
function Builder:CanBuild(recname)
	if self.freebuildmode then
		return true
	end

	local recipe = GetRecipe(recname)
	if recipe then
		for ik, iv in pairs(recipe.ingredients) do
			if iv.ingtype == "VARIABLE" then
				local found = false
				for k,v in pairs(iv.ingredients) do
					found = found or CheckIngredient(self,v)
				end
				if not found then
					return false
				end
			else
				if not CheckIngredient(self,iv) then
					return false
				end
			end
		end
		return true
	end

	return false
end

return Builder