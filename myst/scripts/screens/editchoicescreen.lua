local Screen = require "widgets/screen"
local Menu = require "widgets/menu"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local EditChoiceScreen = Class(Screen, function(self, data, key, choices, title)
	Screen._ctor(self, "EditChoiceScreen")

	self.active = true
	SetPause(true)

	self.data = data
	self.key = key
	self.choices = choices

	--Tint
	self.black = self:AddChild(Image("images/global.xml", "square.tex"))
	self.black:SetVRegPoint(ANCHOR_MIDDLE)
	self.black:SetHRegPoint(ANCHOR_MIDDLE)
	self.black:SetVAnchor(ANCHOR_MIDDLE)
	self.black:SetHAnchor(ANCHOR_MIDDLE)
	self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.black:SetTint(0,0,0,.75)

	--Root
	self.root = self:AddChild(Widget("ROOT"))
	self.root:SetVAnchor(ANCHOR_MIDDLE)
	self.root:SetHAnchor(ANCHOR_MIDDLE)
	self.root:SetPosition(0,0,0)
	self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)

	--Text
	self.text = self.root:AddChild(Text(TITLEFONT, 50))
	self.text:SetPosition(0, 250, 0)
	self.text:SetString(title)

	--Choice List
	self.menu = self.root:AddChild(Menu(nil, -80, false))
	self.menu:SetPosition(0,100,0)
	self.menu:SetScale(0.75,0.75,0.75)

	for k,v in pairs(self.choices) do
		if v.data == self.data[self.key] then
			self.selected = k
		end
	end

	self.listoffset = 0
	self:RefreshList()

	--Scroll Up Button
	self.up = self.root:AddChild(ImageButton())--"images/ui/arrows.xml","arrow_up.tex","arrow_up_over.tex"))
	self.up:SetPosition(250,100,0)
	self.up:SetScale(0.5,0.5,0.5)
	self.up:SetOnClick(function() self:OnClickUp() end)

	--Scroll Down Button
	self.down = self.root:AddChild(ImageButton())--"images/ui/arrows.xml","arrow_down.tex","arrow_down_over.tex"))
	self.down:SetPosition(250,-100,0)
	self.down:SetScale(0.5,0.5,0.5)
	self.down:SetOnClick(function() self:OnClickDown() end)

	--Confirm Button
	self.button = self.root:AddChild(ImageButton())
	self.button:SetPosition(250,0,0)
	self.button:SetScale(0.75,0.75,0.75)
	self.button:SetText(STRINGS.UI.CONFIRM)
	self.button.text:SetColour(0,0,0,1)
	self.button:SetOnClick(function() self:OnConfirm() end)
	self.button:SetFont(BUTTONFONT)
	self.button:SetTextSize(40)

	TheInputProxy:SetCursorVisible(true)
end)

function EditChoiceScreen:OnClickUp()
	self.listoffset = math.max(self.listoffset - 1, 0)
	self:RefreshList()
end

function EditChoiceScreen:OnClickDown()
	self.listoffset = math.min(self.listoffset + 1, math.max(0, GetLength(self.room_choices) - 5))
	self:RefreshList()
end

function EditChoiceScreen:OnConfirm()
	if self.selected then
		self.data[self.key] = self.choices[self.selected].data
		self:Close()
	end
end

function EditChoiceScreen:RefreshList()
	self.menu:Clear()

	for i=1,math.min(GetLength(self.choices),5) do
		if self.choices[i+self.listoffset] then
			local tile = self:MakeTile(self.choices[i+self.listoffset], i+self.listoffset)
			self.menu:AddCustomItem(tile)
		end
	end
end

function EditChoiceScreen:MakeTile(data, key)
	local widget = Widget("choicetile")
	widget.base = widget:AddChild(Widget("base"))

	widget.bg = widget.base:AddChild(UIAnim())
	widget.bg:GetAnimState():SetBuild("savetile") --TODO: Clone anim
	widget.bg:GetAnimState():SetBank("savetile")
	widget.bg:GetAnimState():PlayAnimation("anim")
	widget.bg:SetScale(1.2,.8,1)
	
	widget.portraitbg = widget.base:AddChild(Image("images/saveslot_portraits.xml", "background.tex"))
	widget.portraitbg:SetScale(.60,.60,1)
	widget.portraitbg:SetPosition(-140, 0, 0)

	widget.portraitbg:SetClickable(false)	
	
	--TODO: Adjust for custom icons

	--[[widget.portrait = widget.base:AddChild(Image())
	widget.portrait:SetClickable(false)	
	if character and mode then	
		local atlas = (table.contains(MODCHARACTERLIST, character) and "images/saveslot_portraits/"..character..".xml") or "images/saveslot_portraits.xml"
		widget.portrait:SetTexture(atlas, character..".tex")
	else
		widget.portraitbg:Hide()
	end

	widget.portrait:SetScale(.60,.60,1)
	widget.portrait:SetPosition(-120 + 40, 0, 0)
	]]

	--TODO: Maybe a DLC indicator?

	--[[if character and mode and RoG then
		widget.dlcindicator = widget.base:AddChild(Image())
		widget.dlcindicator:SetClickable(false)
		widget.dlcindicator:SetTexture("images/ui.xml", "DLCicon.tex")
		widget.dlcindicator:SetScale(.5,.5,1)
		widget.dlcindicator:SetPosition(-142, 2, 0)
	end]]

	widget.text = widget.base:AddChild(Text(TITLEFONT, 40))
	widget.text:SetPosition(0,0,0)
	widget.text:SetRegionSize(300 ,70)
	if self.selected == key then
		widget.text:SetColour(0,0,1,1)
	end

	widget.text:SetString(data.name)
	
	widget.text:SetVAlign(ANCHOR_MIDDLE)

	--
	
	widget.OnGainFocus = function(self)
		Widget.OnGainFocus(self)
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
		widget.bg:SetScale(1.25,.87,1)
		widget.bg:GetAnimState():PlayAnimation("over")
	end

	widget.OnLoseFocus = function(self)
		Widget.OnLoseFocus(self)
		widget.base:SetPosition(0,0,0)
		widget.bg:SetScale(1.2,.8,1)
		widget.bg:GetAnimState():PlayAnimation("anim")
	end
		
	local screen = self
	widget.OnControl = function(self, control, down)
		if control == CONTROL_ACCEPT then
			if down then
				widget.base:SetPosition(0,-5,0)
				screen:OnClickTile(key)
			else
				widget.base:SetPosition(0,0,0)
			end
			return true
		end
	end

	return widget
end

function EditChoiceScreen:OnClickTile(key)
	self.selected = key
	self:RefreshList()
end

function EditChoiceScreen:Close()
	self.active = false
	TheFrontEnd:PopScreen(self)
	SetPause(false)
end

function EditChoiceScreen:OnControl(control, down)
	if EditChoiceScreen._base.OnControl(self, control, down) then return true end

	if (control == CONTROL_PAUSE or control == CONTROL_CANCEL) and not down then
		self:Close()
		return true
	end
end

function EditChoiceScreen:OnUpdate(dt)
	if self.active then
		SetPause(true)
	end
end

function EditChoiceScreen:OnBecomeActive()
	EditChoiceScreen._base.OnBecomeActive(self)
	TheFrontEnd:HideTopFade()

	self.root:Show()
	self.black:Show()

	self:RefreshList()
end

return EditChoiceScreen