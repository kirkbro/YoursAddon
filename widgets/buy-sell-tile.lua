_, ns = ...

ns.Widgets = ns.Widgets or {}

ns.Widgets.BuySellTile = {
  parent = nil,
  frame = nil,

  type = nil,
  strategies = nil,
  priceTotalCopper = nil,

  strategy = nil,
  quantity = nil,
  limit = nil,
  priceGold = nil,
  priceSilver = nil,
  priceChange = nil,
  status = nil,

  onClickHandler = nil,
}

--------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
--------------------------------------------------------------------------------

function ns.Widgets.BuySellTile:New(parent, type, strategies)
  local o = {
    parent = parent,
    type = type,
    strategies = strategies,
  }
  setmetatable(o, self)
  self.__index = self

  o:_Init()

  return o
end

function ns.Widgets.BuySellTile:GetStrategy()
  return self.strategy:GetText()
end

function ns.Widgets.BuySellTile:SetStrategy(strategy)
  if ns.Util:IndexOf(self.strategies, strategy) == nil then
    return
  end

  self.strategy:SetText(strategy)
end

function ns.Widgets.BuySellTile:NextStrategy()
  local i = ns.Util:IndexOf(self.strategies, self:GetStrategy())
  i = i % #self.strategies + 1
  self.strategy:SetText(self.strategies[i])
end

function ns.Widgets.BuySellTile:GetQuantity()
  return self.quantity:GetNumber()
end

function ns.Widgets.BuySellTile:SetQuantity(quantity)
  self.quantity:SetText(quantity)
end

function ns.Widgets.BuySellTile:GetLimit()
  return self.limit:GetNumber() * 100
end

function ns.Widgets.BuySellTile:SetLimit(limit)
  self.limit:SetText(limit / 100)
end

function ns.Widgets.BuySellTile:GetStatus()
  return self.status:GetText()
end

function ns.Widgets.BuySellTile:SetStatus(status)
  self.status:SetText(status)
end

function ns.Widgets.BuySellTile:GetPrice()
  return self.priceTotalCopper
end

function ns.Widgets.BuySellTile:SetPrice(totalCopper)
  -- Price change
  if self.priceTotalCopper == nil or self.priceTotalCopper == totalCopper then
    self.priceChange:SetText("")
  elseif self.priceTotalCopper < totalCopper then
    self.priceChange:SetText("▲")
  else
    self.priceChange:SetText("▼")
  end
  self.priceTotalCopper = totalCopper

  -- Gold/silver text
  local gold, silver, _ = ns.Util:MoneyParts(totalCopper)

  if gold < 10 then
    gold = "0"..gold
  end

  if silver < 10 then
    silver = "0"..silver
  end

  self.priceGold:SetText(gold)
  self.priceSilver:SetText(silver)
end

function ns.Widgets.BuySellTile:RegisterOnClick(handler)
  self.onClickHandler = handler
end

--------------------------------------------------------------------------------
-- PRIVATE FUNCTIONS
--------------------------------------------------------------------------------

function ns.Widgets.BuySellTile:_Init()
  -- Frame/button
  self.frame = CreateFrame("Button", nil, self.parent)
  self.frame:SetSize(124, 97)
  local _ = self.frame:CreateTexture()
  _:SetAllPoints()
  _:SetDrawLayer("BACKGROUND")
  if self.type == "buy" then
    _:SetColorTexture(101/255, 38/255, 35/255)
  else
    _:SetColorTexture(29/255, 60/255, 54/255)
  end
  self.frame:RegisterForClicks("AnyUp");
  self.frame:SetScript("OnClick", function() self:_OnClick() end);

  -- Strategy
  local strategyButton = CreateFrame("Button", nil, self.frame)
  if self.type == "buy" then
    strategyButton:SetPoint("TOPRIGHT")
    strategyButton:SetPoint("BOTTOMLEFT", self.frame, "TOP", 0, -28)
  else
    strategyButton:SetPoint("TOPLEFT")
    strategyButton:SetPoint("BOTTOMRIGHT", self.frame, "TOP", 0, -28)
  end

  strategyButton:RegisterForClicks("AnyUp");
  strategyButton:SetScript("OnClick", function() self:NextStrategy() end);

  self.strategy = strategyButton:CreateFontString()
  if self.type == "buy" then
    self.strategy:SetPoint("RIGHT", -8, 0)
  else
    self.strategy:SetPoint("LEFT", 8, 0)
  end
  self.strategy:SetFont("Fonts\\ARIALN.ttf", 9)
  self.strategy:SetTextColor(1, 1, 1, .8)
  self.strategy:SetText(self.strategies[1])

  -- Quantity
  self.quantity = CreateFrame("EditBox", nil, self.frame)
  if self.type == "buy" then
    self.quantity:SetPoint("TOPLEFT", 8, -10)
  else
    self.quantity:SetPoint("TOPRIGHT", -8, -10)
  end
  self.quantity:SetSize(50, 9)
  self.quantity:SetFont("Fonts\\ARIALN.ttf", 12, "")
  self.quantity:SetTextColor(1, 1, 1)
  self.quantity:SetJustifyH(self.type == "buy" and "LEFT" or "RIGHT")
  self.quantity:SetNumeric()
  self.quantity:SetAutoFocus(false)
  self.quantity:SetText(0)

  -- Separator
  local _ = self.frame:CreateTexture()
  _:SetPoint("TOPLEFT", 0, -28)
  _:SetPoint("TOPRIGHT", 0, -28)
  _:SetSize(-1, 1)
  _:SetDrawLayer("BORDER")
  _:SetColorTexture(1, 1, 1, .5)

  -- Limit title
  local _ = self.frame:CreateFontString()
  if self.type == "buy" then
    _:SetPoint("TOPRIGHT", -8, -34)
  else
    _:SetPoint("TOPLEFT", 8, -34)
  end
  _:SetFont("Fonts\\ARIALN.ttf", 8)
  _:SetTextColor(1, 1, 1, .8)
  _:SetText("LIMIT")

  -- Limit
  self.limit = CreateFrame("EditBox", nil, self.frame)
  if self.type == "buy" then
    self.limit:SetPoint("TOPLEFT", 8, -34)
  else
    self.limit:SetPoint("TOPRIGHT", -8, -34)
  end
  self.limit:SetSize(50, 10)
  self.limit:SetFont("Fonts\\ARIALN.ttf", 10, "")
  self.limit:SetTextColor(1, 1, 1)
  self.limit:SetJustifyH(self.type == "buy" and "LEFT" or "RIGHT")
  self.limit:SetNumeric()
  self.limit:SetAutoFocus(false)
  self.limit:SetText(0)

  -- Price texts
  self.priceGold = self.frame:CreateFontString()
  self.priceGold:SetPoint("BOTTOMLEFT", self.frame, "TOPLEFT", -1, -75)
  self.priceGold:SetPoint("BOTTOMRIGHT", self.frame, "TOP", -1, -75)
  self.priceGold:SetFont("Fonts\\ARIALN.ttf", 22, "")
  self.priceGold:SetTextColor(1, 1, 1)
  self.priceGold:SetJustifyH("RIGHT")
  self.priceGold:SetText("00")

  self.priceSilver = self.frame:CreateFontString()
  self.priceSilver:SetPoint("BOTTOMRIGHT", self.frame, "TOPRIGHT", 1, -75)
  self.priceSilver:SetPoint("BOTTOMLEFT", self.frame, "TOP", 1, -75)
  self.priceSilver:SetFont("Fonts\\ARIALN.ttf", 16, "")
  self.priceSilver:SetTextColor(1, 1, 1, .7)
  self.priceSilver:SetJustifyH("LEFT")
  self.priceSilver:SetText("00")

  -- Price change
  self.priceChange = self.frame:CreateFontString()
  if self.type == "buy" then
    self.priceChange:SetPoint("BOTTOMRIGHT", self.frame, "TOPRIGHT", -8, -75)
  else
    self.priceChange:SetPoint("BOTTOMLEFT", self.frame, "TOPLEFT", 8, -75)
  end
  self.priceChange:SetFont("Fonts\\ARIALN.ttf", 10, "")
  self.priceChange:SetTextColor(1, 1, 1)
  self.priceChange:SetText("")

  -- Separator
  local _ = self.frame:CreateTexture()
  _:SetPoint("TOPLEFT", 0, -80)
  _:SetPoint("TOPRIGHT", 0, -80)
  _:SetSize(-1, 1)
  _:SetDrawLayer("BORDER")
  _:SetColorTexture(1, 1, 1, .5)

  self.status = self.frame:CreateFontString()
  self.status:SetPoint("BOTTOM", 0, 4)
  self.status:SetFont("Fonts\\ARIALN.ttf", 8, "")
  self.status:SetTextColor(1, 1, 1, .8)
  self.status:SetText("")
end

function ns.Widgets.BuySellTile:_OnClick()
  if self.onClickHandler ~= nil then
    self.onClickHandler()
  end
end
