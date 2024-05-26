local Screen = require "widgets/screen"
local Menu = require "widgets/menu"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local TextEdit = require "widgets/textedit"

local VALID_CHARS = [[ abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789]]
local label_height = 50
local fontsize = 30
local edit_width = 300
local edit_bg_padding = 100

local EditStringScreen = Class(Screen, function(self, data, key, title)
	Screen._ctor(self, "EditStringScreen")

	self.active = true
	SetPause(true)

	self.data = data
	self.key = key

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
	self.text:SetPosition(0, 100, 0)
	self.text:SetString(title)

	--Text Box
	self.textedit_bg = self.root:AddChild(Image())
	self.textedit_bg:SetTexture("images/ui.xml", "textbox_long.tex")
	self.textedit_bg:SetPosition(0,0,0)
	self.textedit_bg:ScaleToSize(edit_width + edit_bg_padding, label_height)

	--Text Entry
	self.textedit = self.root:AddChild(TextEdit(DEFAULTFONT, fontsize, ""))
	self.textedit:SetPosition(0,0,0)
	self.textedit:SetRegionSize(edit_width, label_height)
	self.textedit:SetHAlign(ANCHOR_MIDDLE)
	self.textedit:SetFocusedImage(self.textedit_bg, "images/ui.xml", "textbox_long_over.tex", "textbox_long.tex")
	self.textedit:SetCharacterFilter(VALID_CHARS)

	self.textedit:SetString(self.data[self.key])

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

function EditStringScreen:OnConfirm()
	self.data[self.key] = self.textedit:GetString()
	self:Close()
end

function EditStringScreen:Close()
	self.active = false
	TheFrontEnd:PopScreen(self)
	SetPause(false)
end

function EditStringScreen:OnControl(control, down)
	if EditStringScreen._base.OnControl(self, control, down) then return true end

	if (control == CONTROL_PAUSE or control == CONTROL_CANCEL) and not down then
		self:Close()
		return true
	end
end

function EditStringScreen:OnUpdate(dt)
	if self.active then
		SetPause(true)
	end
end

function EditStringScreen:OnBecomeActive()
	EditStringScreen._base.OnBecomeActive(self)
	TheFrontEnd:HideTopFade()

	self.root:Show()
	self.black:Show()
end

return EditStringScreen