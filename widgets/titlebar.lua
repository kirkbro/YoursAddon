_, ns = ...

ns.Widgets = ns.Widgets or {}

ns.Widgets.Titlebar = {
  parent = nil,
  frame = nil,

  onSelectHandler = nil,
  onCloseHandler = nil,

  background = nil,
  icon = nil,
  text = nil,
  closeButton = nil,
}

--------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
--------------------------------------------------------------------------------

function ns.Widgets.Titlebar:New(parent)
  local o = {
    parent = parent,
  }
  setmetatable(o, self)
  self.__index = self

  o:_Init()

  return o
end

function ns.Widgets.Titlebar:SetHighlight(highlighted)
  if highlighted then
    self.background:SetColorTexture(29/255, 60/255, 54/255)
  else
    self.background:SetColorTexture(17/255, 20/255, 26/255)
  end
end

function ns.Widgets.Titlebar:SetIcon(texture)
  self.icon:SetTexture(texture)
end

function ns.Widgets.Titlebar:SetText(text)
  self.text:SetText(text)
end

function ns.Widgets.Titlebar:SetItem(itemId)
  local itemName, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemId)

  self:SetIcon(itemTexture)
  self:SetText(itemName)
end

function ns.Widgets.Titlebar:RegisterOnSelect(handler)
  self.onSelectHandler = handler
end

function ns.Widgets.Titlebar:RegisterOnClose(handler)
  self.onCloseHandler = handler
end

--------------------------------------------------------------------------------
-- PRIVATE FUNCTIONS
--------------------------------------------------------------------------------

function ns.Widgets.Titlebar:_Init()
  -- Containing frame
  self.frame = CreateFrame("Button", nil, self.parent)
  self.frame:SetPoint("TOPLEFT")
  self.frame:SetPoint("TOPRIGHT")
  self.frame:SetSize(-1, 25)
  self.frame:EnableMouse(true)

  -- Register click
  self.frame:RegisterForClicks("AnyUp");
  self.frame:SetScript("OnClick", function(...) self:_OnSelect() end);

  -- Register drag
  -- Note we invoke StartMoving and StopMovingOrSizing on the parent frame
  self.frame:RegisterForDrag("LeftButton")
  self.frame:SetScript("OnDragStart", function (...) self.parent:StartMoving() end)
  self.frame:SetScript("OnDragStop", function (...) self.parent:StopMovingOrSizing() end)

  -- Title background
  self.background = self.frame:CreateTexture(nil, "BACKGROUND")
  self.background:SetAllPoints()
  self.background:SetColorTexture(17/255, 20/255, 26/255)

  -- Title icon
  self.icon = self.frame:CreateTexture()
  self.icon:SetPoint("LEFT", 8, 0)
  self.icon:SetSize(15, 15)

  -- Title text
  self.text = self.frame:CreateFontString()
  self.text:SetPoint("LEFT", 30, 0)
  self.text:SetFont("Fonts\\ARIALN.ttf", 12)
  self.text:SetTextColor(1, 1, 1)

  -- Close button
  self.closeButton = CreateFrame("Button", nil, self.frame)
  self.closeButton:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT")
  self.closeButton:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT")
  self.closeButton:SetSize(20, -1)
  self.closeButton:RegisterForClicks("AnyUp");
  self.closeButton:SetScript("OnClick", function(...) self:_OnClose() end);

  -- Close button icon
  local _ = self.closeButton:CreateFontString()
  _:SetPoint("CENTER")
  _:SetFont("Fonts\\ARIALN.ttf", 9)
  _:SetTextColor(1, 1, 1, .8)
  _:SetText("X")
end

function ns.Widgets.Titlebar:_OnSelect()
  if self.onSelectHandler ~= nil then
    self.onSelectHandler(self)
  end
end

function ns.Widgets.Titlebar:_OnClose()
  if self.onCloseHandler ~= nil then
    self.onCloseHandler(self)
  end
end
