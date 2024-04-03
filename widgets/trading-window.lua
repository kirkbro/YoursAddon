_, ns = ...

--------------------------------------------------------------------------------
-- BUY ALGO CALLBACKS
--------------------------------------------------------------------------------

local BuyCallback = {
  window = nil,
}

function BuyCallback:New(window)
  local o = {
    window = window,
  }

  setmetatable(o, self)
  self.__index = self
  return o
end

function BuyCallback:OnStatus(status)
  self.window.dealingTile.buyTile:SetStatus(status)
end

function BuyCallback:OnPrice(price)
  self.window.dealingTile.buyTile:SetPrice(price)
end

function BuyCallback:OnBook(book)
  local levels = math.min(
    book:GetLength(),
    self.window.dealingTile.bookTile:GetNumLevels())

  for level=1, levels do
    local price, quantity = book:FastGetLevel(level)
    self.window.dealingTile.bookTile:SetLevel(
      level,
      price,
      quantity,
      price <= self.window.dealingTile.buyTile:GetLimit())
  end
end

--------------------------------------------------------------------------------
-- SELL ALGO CALLBACKS
--------------------------------------------------------------------------------

local SellCallback = {
  window = nil,
}

function SellCallback:New(window)
  local o = {
    window = window,
  }

  setmetatable(o, self)
  self.__index = self
  return o
end

function SellCallback:OnStatus(status)
  self.window.dealingTile.sellTile:SetStatus(status)
end

function SellCallback:OnPrice(price)
  self.window.dealingTile.sellTile:SetPrice(price)
end

--------------------------------------------------------------------------------

ns.Widgets = ns.Widgets or {}

ns.Widgets.TradingWindow = {
  parent = nil,
  frame = nil,

  itemId = nil,

  titlebar = nil,
  dealingTile = nil,

  onSelectHandler = nil,
  onCloseHandler = nil,

  fixedBuyAlgo = nil,
  dynamicBuyAlgo = nil,
  fixedSellAlgo = nil,

  buyCallback = nil,
  sellCallback = nil,
}

--------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
--------------------------------------------------------------------------------

function ns.Widgets.TradingWindow:New(parent, settings)
  local o = {
    parent = parent,
    fixedBuyAlgo = ns.Algos.FixedBuy:New(),
    dynamicBuyAlgo = ns.Algos.DynamicBuy:New(),
    fixedSellAlgo = ns.Algos.FixedSell:New(),
  }

  setmetatable(o, self)
  self.__index = self

  o:_Init(settings)

  return o
end

function ns.Widgets.TradingWindow:GetItemId()
  return self.itemId
end

function ns.Widgets.TradingWindow:GetSettings()
  local point, x, y = self:GetPosition()
  return {
    type = "TRADING_WINDOW",
    position = {point = point, x = x, y = y},
    custom = {
      itemId = self.itemId,

      isAdvancedShown = self.dealingTile:IsAdvancedShown(),

      buyStrategy = self.dealingTile.buyTile:GetStrategy(),
      buyQuantity = self.dealingTile.buyTile:GetQuantity(),
      buyLimit = self.dealingTile.buyTile:GetLimit(),

      sellStrategy = self.dealingTile.sellTile:GetStrategy(),
      sellQuantity = self.dealingTile.sellTile:GetQuantity(),
      sellLimit = self.dealingTile.sellTile:GetLimit(),

      minQuantity = self.dealingTile.optionsTile:GetOption("MIN QTY"),
      sweepFactor = self.dealingTile.optionsTile:GetOption("SWEEP %"),
      maxLevels = self.dealingTile.optionsTile:GetOption("MAX LEVELS"),
    },
  }
end

function ns.Widgets.TradingWindow:Show()
  self.frame:Show()
end

function ns.Widgets.TradingWindow:Hide()
  self.frame:Hide()
end

function ns.Widgets.TradingWindow:Close()
  self:_OnClose()
end

function ns.Widgets.TradingWindow:GetPosition()
  local _, _, point, x, y = self.frame:GetPoint()
  return point, x, y
end

function ns.Widgets.TradingWindow:SetPosition(point, x, y)
  self.frame:ClearAllPoints()
  self.frame:SetPoint(point, UIParent, point, x, y)
end

function ns.Widgets.TradingWindow:SetActive(active)
  self.titlebar:SetHighlight(active)
end

function ns.Widgets.TradingWindow:Buy()
  local strategy = self.dealingTile.buyTile:GetStrategy()

  -- BUY
  if strategy == 'BUY' then
    local algo = self.fixedBuyAlgo
    if algo:IsIdle() then
      local quantity = self.dealingTile.buyTile:GetQuantity()
      local limit = self.dealingTile.buyTile:GetLimit()

      algo:Configure(
        self.buyCallback,
        self.itemId,
        quantity,
        limit)
    end
    
    algo:Work()

  -- SWEEP
  elseif strategy == 'SWEEP' then
    local algo = self.dynamicBuyAlgo
    if algo:IsIdle() then
      local maxQuantity = self.dealingTile.buyTile:GetQuantity()
      local limit = self.dealingTile.buyTile:GetLimit()
      local minQuantity = self.dealingTile.optionsTile:GetOption("MIN QTY")
      local sweepFactor = self.dealingTile.optionsTile:GetOption("SWEEP %") / 100
      local maxLevels = self.dealingTile.optionsTile:GetOption("MAX LEVELS")

      algo:Configure(
        self.buyCallback,
        self.itemId,
        minQuantity,
        maxQuantity,
        sweepFactor,
        maxLevels,
        limit)
    end

    algo:Work()
  end
end

function ns.Widgets.TradingWindow:Sell()
  local strategy = self.dealingTile.sellTile:GetStrategy()

  if strategy == 'SELL' then
    local algo = self.fixedSellAlgo
    if algo:IsIdle() then
      local quantity = self.dealingTile.sellTile:GetQuantity()
      local limit = self.dealingTile.sellTile:GetLimit()

      algo:Configure(
        self.sellCallback,
        self.itemId,
        quantity,
        limit)
    end
    
    algo:Work()
  end
end

function ns.Widgets.TradingWindow:RegisterOnSelect(handler)
  self.onSelectHandler = handler
end

function ns.Widgets.TradingWindow:RegisterOnClose(handler)
  self.onCloseHandler = handler
end

--------------------------------------------------------------------------------
-- PRIVATE FUNCTIONS
--------------------------------------------------------------------------------

function ns.Widgets.TradingWindow:_Init(settings)
  -- Callbacks
  self.buyCallback = BuyCallback:New(self)
  self.sellCallback = SellCallback:New(self)

  -- Frame
  self.frame = CreateFrame("Frame", nil, self.parent)
  self.frame:SetPoint("CENTER", UIParent, "CENTER")
  self.frame:SetSize(285, -1)
  self.frame:SetMovable(true)

  -- Titlebar
  self.titlebar = ns.Widgets.Titlebar:New(self.frame)
  self.titlebar:RegisterOnSelect(function (...) self:_OnSelect() end)
  self.titlebar:RegisterOnClose(function (...) self:_OnClose() end)

  -- Dealing tile
  self.dealingTile = ns.Widgets.DealingTile:New(self.titlebar.frame)
  self.dealingTile.buyTile:RegisterOnClick(function (...) self:Buy() end)
  self.dealingTile.sellTile:RegisterOnClick(function (...) self:Sell() end)

  -- Adjust custom settings
  self.itemId = settings.custom["itemId"]
  self.titlebar:SetItem(self.itemId)

  self.dealingTile:ToggleAdvanced(settings.custom["isAdvancedShown"] or false)

  self.dealingTile.buyTile:SetStrategy(settings.custom["buyStrategy"] or nil)
  self.dealingTile.buyTile:SetQuantity(settings.custom["buyQuantity"] or 10)
  self.dealingTile.buyTile:SetLimit(settings.custom["buyLimit"] or 100)

  self.dealingTile.sellTile:SetStrategy(settings.custom["sellStrategy"] or nil)
  self.dealingTile.sellTile:SetQuantity(settings.custom["sellQuantity"] or 1)
  self.dealingTile.sellTile:SetLimit(settings.custom["sellLimit"] or 100)

  self.dealingTile.optionsTile:SetOption("MIN QTY", settings.custom["minQuantity"] or 5)
  self.dealingTile.optionsTile:SetOption("SWEEP %", settings.custom["sweepFactor"] or 80)
  self.dealingTile.optionsTile:SetOption("MAX LEVELS", settings.custom["maxLevels"] or 6)

  -- Reposition if available
  if settings.position ~= nil then
    self:SetPosition(
      settings.position.point,
      settings.position.x,
      settings.position.y)
  end
end

function ns.Widgets.TradingWindow:_OnSelect()
  if self.onSelectHandler ~= nil then
    self.onSelectHandler(self)
  end
end

function ns.Widgets.TradingWindow:_OnClose()
  self.frame:Hide()

  if self.onCloseHandler ~= nil then
    self.onCloseHandler(self)
  end
end
