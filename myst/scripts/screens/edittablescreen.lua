local Screen = require "widgets/screen"
local Menu = require "widgets/menu"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local EditStringScreen = require "screens/editstringscreen"
local EditChoiceScreen = require "screens/editchoicescreen"

local EditTableScreen = Class(Screen, function(self, data, template, cb)
	Screen._ctor(self, "EditTableScreen")

	self.active = true
	SetPause(true)

	self.data = data
	self.template = template
	self.cb = cb

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
	self:RefreshTitle()

	--Property List
	self.menu = self.root:AddChild(Menu(nil, -80, false))
	self.menu:SetPosition(0,100,0)
	self.menu:SetScale(0.75,0.75,0.75)

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

	TheInputProxy:SetCursorVisible(true)
end)

function EditTableScreen:RefreshTitle()
	local title = self.template.__TITLE
	if type(title) == "function" then
		title = title(self.data)
	end
	self.text:SetString(title)
end

function EditTableScreen:OnClickUp()
	self.listoffset = math.max(self.listoffset - 1, 0)
	self:RefreshList()
end

function EditTableScreen:OnClickDown()
	self.listoffset = math.min(self.listoffset + 1, math.max(0, GetLength(self.data) - 5))
	self:RefreshList()
end

local function GetSortedList(data)
	local list = {}
	for k,v in pairs(data) do
		table.insert(list,k)
	end
	table.sort(list)

	for i,k in ipairs(list) do
		list[i] = {k,data[k]}
	end

	return list
end

function EditTableScreen:RefreshList()
	self.menu:Clear()

	local list = GetSortedList(self.data)

	for i=1,math.min(GetLength(list),5) do
		if list[i+self.listoffset] then
			if not self:IsKeyHidden(list[i+self.listoffset][1]) then
				local tile = self:MakeTile(list[i+self.listoffset])
				self.menu:AddCustomItem(tile)
			end
		end
	end
end

function EditTableScreen:GetNameFromTemplate(key)
	if self.template[key] then
		return self.template[key].name
	else
		return nil
	end
end

function EditTableScreen:GetPropertyTypeFromTemplate(key)
	if self.template[key] then
		return self.template[key].type or type(key)
	else
		return type(self.data[key])
	end
end

function EditTableScreen:IsKeyHidden(key)
	if self.template[key] then
		if self.template[key].hide then
			return true
		end
	end
	return false
end

function EditTableScreen:MakeTile(data)
	local widget = Widget("propertytile")
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

	widget.text = widget.base:AddChild(Text(TITLEFONT, 40))
	widget.text:SetPosition(0,0,0)
	widget.text:SetRegionSize(300 ,70)

	local name = self:GetNameFromTemplate(data[1]) or data[1]

	widget.text:SetString(name)
	
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
			else
				widget.base:SetPosition(0,0,0)
				screen:OnClickTile(data[1])
			end
			return true
		end
	end

	return widget
end

function EditTableScreen:OnClickString(key)
	self.root:Hide()
	self.black:Hide()

	local title = tostring(key)
	if self.template[key] then
		title = self.template[key].name
	end
	TheFrontEnd:PushScreen(EditStringScreen(self.data, key, title))
end

function EditTableScreen:OnClickChoice(key)
	self.root:Hide()
	self.black:Hide()

	local title = tostring(key)
	if self.template[key] then
		title = self.template[key].name
	end
	local choice_set = GetChoiceSet(self.template[key].choice_set)
	TheFrontEnd:PushScreen(EditChoiceScreen(self.data, key, choice_set, title))
end

function EditTableScreen:OnClickTile(key)
	local functions = {
		["string"]=self.OnClickString,
		["choice"]=self.OnClickChoice
	}
	local keytype = self:GetPropertyTypeFromTemplate(key)
	local fn = functions[keytype] or function() print("Not Implemented") end
	fn(self, key)
end

function EditTableScreen:Close(cb)
	self.active = false
	TheFrontEnd:PopScreen(self)
	SetPause(false)

	if cb then
		cb(self)
	end
end

function EditTableScreen:OnControl(control, down)
	if EditTableScreen._base.OnControl(self, control, down) then return true end

	if (control == CONTROL_PAUSE or control == CONTROL_CANCEL) and not down then
		self:Close(self.cb)
		return true
	end
end

function EditTableScreen:OnUpdate(dt)
	if self.active then
		SetPause(true)
	end
end

function EditTableScreen:OnBecomeActive()
	EditTableScreen._base.OnBecomeActive(self)
	TheFrontEnd:HideTopFade()

	self.root:Show()
	self.black:Show()

	self:RefreshTitle()
	self:RefreshList()
end

return EditTableScreen