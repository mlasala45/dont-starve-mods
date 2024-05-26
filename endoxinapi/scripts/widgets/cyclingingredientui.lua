require "class"

local TileBG = require "widgets/tilebg"
local InventorySlot = require "widgets/invslot"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local TabGroup = require "widgets/tabgroup"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"


local CyclingIngredientUI = Class(Widget, function(self, ingredients, owner)
	Widget._ctor(self, "CyclingIngredientUI")
	
	self.atlases = {}
	self.images = {}
	self.quantities = {}
	self.on_hand = {}
	self.has_enough = {}
	self.names = {}

	for k,v in pairs(ingredients) do
		self.atlases[k] = v.atlas
		if SaveGameIndex:IsModeShipwrecked() and SW_ICONS[v.type] ~= nil then
			self.images[k] = SW_ICONS[v.type]..".tex"
		else
			self.images[k] = v.type..".tex"
		end
		if owner and owner.components.builder then
			self.quantities[k] = RoundUp(v.amount * owner.components.builder.ingredientmod)
		else
			self.quantities[k] = v.amount
		end
		if v.ingtype == "SPECIAL" then
			local amt = v.amtfn(owner)
			self.has_enough[k], self.on_hand[k] = amt >= v.amount, amt
		else
			self.has_enough[k], self.on_hand[k] = owner.components.inventory:Has(v.type, RoundUp(v.amount * owner.components.builder.ingredientmod))
		end
		self.names[k] = STRINGS.NAMES[string.upper(v.type)]
	end

	self.n = 1

	local hud_atlas = resolvefilepath("images/hud.xml")

	if self.has_enough[self.n] then
		self.bg = self:AddChild(Image(hud_atlas, "inv_slot.tex"))
	else
		self.bg = self:AddChild(Image(hud_atlas, "resource_needed.tex"))
	end

	self.ing = self:AddChild(Image(self.atlases[self.n], self.images[self.n]))

	if JapaneseOnPS4() then
		self.quant = self:AddChild(Text(SMALLNUMBERFONT, 30))
	else
		self.quant = self:AddChild(Text(SMALLNUMBERFONT, 24))
	end
	self.quant:SetPosition(7,-32, 0)

	self:Refresh()
	scheduler:ExecutePeriodic(TUNING.VARIABLE_INGREDIENT_CYCLE_PERIOD,function()
		self:Refresh()
	end)
end)

function CyclingIngredientUI:Refresh()
	local hud_atlas = resolvefilepath("images/hud.xml")

	if self.has_enough[self.n] then
		self.bg:SetTexture(hud_atlas, "inv_slot.tex")
	else
		self.bg:SetTexture(hud_atlas, "resource_needed.tex")
	end

	self:SetTooltip(self.names[self.n])
	
	self.ing:SetTexture(self.atlases[self.n], self.images[self.n])
	if self.quantities[self.n] then
		self.quant:SetString(string.format("%d/%d", self.on_hand[self.n],self.quantities[self.n]))
		if not self.has_enough[self.n] then
			self.quant:SetColour(255/255,155/255,155/255,1)
		else
			self.quant:SetColour(255/255,225/255,225/255,1)
		end
	end

	self.n = self.n+1
	if self.n > #self.images then
		self.n = 1
	end
end

return CyclingIngredientUI
