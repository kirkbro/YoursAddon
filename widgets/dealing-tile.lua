_, ns = ...

ns.Widgets = ns.Widgets or {}

ns.Widgets.DealingTile = {
  parent = nil,
  frame = nil,

  sellTile = nil,
  buyTile = nil,
  bookTile = nil,
  optionsTile = nil,

  advanced = nil,
  toggleAdvancedText = nil
}

--------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
--------------------------------------------------------------------------------

function ns.Widgets.DealingTile:New(parent)
  local o = {
    parent = parent,
  }
  setmetatable(o, self)
  self.__index = self

  o:_Init()

  return o
end

function ns.Widgets.DealingTile:IsAdvancedShown()
  return self.advanced:IsShown()
end

function ns.Widgets.DealingTile:ToggleAdvanced(show)
  if show then
    self.advanced:Show()
    self.toggleAdvancedText:SetText("▲")
  else
    self.advanced:Hide()
    self.toggleAdvancedText:SetText("▼")
  end
end

--------------------------------------------------------------------------------
-- PRIVATE FUNCTIONS
--------------------------------------------------------------------------------

function ns.Widgets.DealingTile:_Init()
  self.frame = CreateFrame("Frame", nil, self.parent)
  self.frame:SetPoint("TOPLEFT", self.parent, "BOTTOMLEFT")
  self.frame:SetPoint("TOPRIGHT", self.parent, "BOTTOMRIGHT")
  self.frame:SetSize(-1, 117)

  -- Background
  local _ = self.frame:CreateTexture(nil, "ARTWORK")
  _:SetAllPoints()
  _:SetColorTexture(26/255, 30/255, 38/255)

  -- Sell tile
  self.sellTile = ns.Widgets.BuySellTile:New(self.frame, "sell", {"SELL"})
  self.sellTile.frame:SetPoint("TOPLEFT", 15, -10)

  -- Buy tile
  self.buyTile = ns.Widgets.BuySellTile:New(self.frame, "buy", {"BUY", "SWEEP"})
  self.buyTile.frame:SetPoint("TOPRIGHT", -15, -10)

  -- Advanced drop-down
  self.advanced = CreateFrame("Frame", nil, self.frame)
  self.advanced:SetPoint("TOPLEFT", self.frame, "BOTTOMLEFT")
  self.advanced:SetPoint("TOPRIGHT", self.frame, "BOTTOMRIGHT")
  self.advanced:SetSize(-1, 158)
  local _ = self.advanced:CreateTexture(nil, "ARTWORK")
  _:SetAllPoints()
  _:SetColorTexture(17/255, 20/255, 26/255)

  -- Advanced drop-down toggle
  local toggleAdvanced = CreateFrame("Button", nil, self.frame)
  toggleAdvanced:SetPoint("BOTTOM", self.frame, "BOTTOM")
  toggleAdvanced:SetSize(20, 10)
  toggleAdvanced:RegisterForClicks("AnyUp");

  self.toggleAdvancedText = toggleAdvanced:CreateFontString()
  self.toggleAdvancedText:SetPoint("CENTER")
  self.toggleAdvancedText:SetJustifyH("CENTER")
  self.toggleAdvancedText:SetFont("Fonts\\ARIALN.ttf", 6)
  self.toggleAdvancedText:SetTextColor(1, 1, 1, 0.8)
  self.toggleAdvancedText:SetText("▼")

  toggleAdvanced:SetScript("OnClick", function(...)
    self:ToggleAdvanced(not self.advanced:IsShown())
  end);

  -- Advanced: Book tile
  local bookFrame = CreateFrame("Frame", nil, self.advanced)
  bookFrame:SetPoint("TOPLEFT", self.advanced, "TOP")
  bookFrame:SetPoint("BOTTOMRIGHT")
  self.bookTile = ns.Widgets.BookTile:New(bookFrame, 6)

  -- Advanced: Options tile
  local optionsFrame = CreateFrame("Frame", nil, self.advanced)
  optionsFrame:SetPoint("TOPRIGHT", self.advanced, "TOP")
  optionsFrame:SetPoint("BOTTOMLEFT")
  self.optionsTile = ns.Widgets.OptionsTile:New(optionsFrame, {
    "MIN QTY",
    "SWEEP %",
    "MAX LEVELS",
  })

  -- Advanced initially hidden
  self:ToggleAdvanced(false)
end
