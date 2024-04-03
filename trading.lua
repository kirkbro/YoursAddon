_, ns = ...

ns.TradingState = EnumUtil.MakeEnum(
  "Idle",
  "BuyQuoteRequested",
  "BuyQuoteLastLook",
  "BuyQuoteAccepted",
  "SellPending",
  "BookRefreshPending",
  "SummaryRefreshPending"
)

ns.Trading = {
  _frame = CreateFrame("Frame"),
  _state = ns.TradingState.Idle,
  _books = {}, -- item ID -> OrderBook

  _callback = nil,
  _itemId = nil,
  _quantity = nil,
  _limit = nil,
  _itemId = nil,
  _numLevels = nil,
}


--------------------------------------------------------------------------------
-- UTILITY FUNCTIONS
--------------------------------------------------------------------------------

local function FindBagItem(itemId)
  for i = 0, NUM_BAG_SLOTS do
    for j = 1, C_Container.GetContainerNumSlots(i) do
      if C_Container.GetContainerItemID(i, j) == itemId then
        return ItemLocation:CreateFromBagAndSlot(i, j)
      end
    end
  end
end

--------------------------------------------------------------------------------
-- PRIVATE FUNCTIONS
--------------------------------------------------------------------------------

function ns.Trading:_OnEventCommodityPriceUpdated(quotedPrice)
  if self._state ~= ns.TradingState.BuyQuoteRequested then
    return
  end

  local accept

  if self._limit ~= nil then
    accept = quotedPrice <= self._limit
  else
    accept = self._callback:OnLastLook(self._itemId, quotedPrice)
  end

  if accept then
    C_AuctionHouse.ConfirmCommoditiesPurchase(self._itemId, self._quantity)

    self._state = ns.TradingState.BuyQuoteAccepted
    self._callback:OnQuoteAccepted(self._itemId, quotedPrice)
  else
    self._state = ns.TradingState.Idle
    self._callback:OnQuotePassed(self._itemId, quotedPrice)
  end
end

function ns.Trading:_OnEventCommodityPriceUnavailable()
  if self._state ~= ns.TradingState.BuyQuoteRequested then
    return
  end

  self._state = ns.TradingState.Idle
  self._callback:OnQuoteUnavailable(self._itemId)
end

function ns.Trading:_OnEventCommodityPurchaseFailed()
  if self._state ~= ns.TradingState.BuyQuoteAccepted then
    return
  end

  self._state = ns.TradingState.Idle
  self._callback:OnTradeRejected(self._itemId)
end

function ns.Trading:_OnEventCommodityPurchaseSucceeded()
  if self._state ~= ns.TradingState.BuyQuoteAccepted then
    return
  end

  self._state = ns.TradingState.Idle
  self._callback:OnTradeFilled(self._itemId)
end

function ns.Trading:_OnEventAuctionHouseAuctionCreated()
  if self._state ~= ns.TradingState.SellPending then
    return
  end

  self._state = ns.TradingState.Idle
  self._callback:OnSellPosted(self._itemId, self._limit)
end

function ns.Trading:_OnEventCommoditySearchResultsUpdated(itemId)
  if self._state ~= ns.TradingState.BookRefreshPending or
      self._itemId ~= itemId or
      not C_AuctionHouse.HasFullCommoditySearchResults(itemId) then

    return
  end

  -- Order book for item
  local book = self:GetBook(itemId)
  book:Clear()

  -- TODO: Write time of order book update

  -- Write total quantity reported
  local totalQuantity = C_AuctionHouse.GetCommoditySearchResultsQuantity(itemId)
  book:SetTotalQuantity(totalQuantity)

  -- Take min of reported amount of levels and requested amount of levels
  local numLevels = C_AuctionHouse.GetNumCommoditySearchResults(itemId)
  if self._numLevels and self._numLevels < numLevels then
    numLevels = self._numLevels
  end

  -- Write order book levels
  for i = 1, numLevels do
    local level = C_AuctionHouse.GetCommoditySearchResultInfo(itemId, i)
    book:AddLevel(level.unitPrice, level.quantity)
  end

  self._state = ns.TradingState.Idle
  self._callback:OnBookRefreshed(itemId)
end

function ns.Trading:_OnAuctionHouseBrowseResultsUpdated()
  if self._state ~= ns.TradingState.SummaryRefreshPending then
    return
  end

  local results = C_AuctionHouse.GetBrowseResults()
  for k=1, #results do local result = results[k];
    result.itemId = result.itemKey.itemID
  end

  self._state = ns.TradingState.Idle
  self._callback:OnSummaryRefreshed(results)
end

function ns.Trading:_OnEventAuctionHouseShowError(error)
  if self._state == ns.TradingState.Idle then
    return
  end

  self._state = ns.TradingState.Idle
  self._callback:OnError(error)
end

function ns.Trading:_OnEvent(_, event, ...)
  if event == "COMMODITY_PRICE_UPDATED" then
    local quotedPrice = ...
    self:_OnEventCommodityPriceUpdated(quotedPrice)
  elseif event == "COMMODITY_PRICE_UNAVAILABLE" then
    self:_OnEventCommodityPriceUnavailable()
  elseif event == "COMMODITY_PURCHASE_FAILED" then
    self:_OnEventCommodityPurchaseFailed()
  elseif event == "COMMODITY_PURCHASE_SUCCEEDED" then
    self:_OnEventCommodityPurchaseSucceeded()
  elseif event == "AUCTION_HOUSE_AUCTION_CREATED" then
    self:_OnEventAuctionHouseAuctionCreated()
  elseif event == "COMMODITY_SEARCH_RESULTS_UPDATED" then
    local itemId = ...
    self:_OnEventCommoditySearchResultsUpdated(itemId)
  elseif event == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then
    self:_OnAuctionHouseBrowseResultsUpdated()
  elseif event == "AUCTION_HOUSE_SHOW_ERROR" then
    local error = ...
    self:_OnEventAuctionHouseShowError(error)
  end
end

--------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
--------------------------------------------------------------------------------

  -- nil limit implies last-look
function ns.Trading:Buy(itemId, quantity, limit, callback)
  if self._state ~= ns.TradingState.Idle then
    callback:OnBusy()
    return
  end

  self._state = ns.TradingState.BuyQuoteRequested
  self._itemId = itemId
  self._quantity = quantity
  self._limit = limit
  self._callback = callback

  C_AuctionHouse.StartCommoditiesPurchase(itemId, quantity)
  callback:OnQuoteRequested(itemId)
end

function ns.Trading:Sell(itemId, quantity, limit, duration, callback)
  if self._state ~= ns.TradingState.Idle then
    callback:OnBusy()
    return
  end

  local item = FindBagItem(itemId)
  if item == nil then
    callback:OnLowInventory(itemId)
    return
  end

  self._state = ns.TradingState.SellPending
  self._itemId = itemId
  self._limit = limit
  self._callback = callback

  C_AuctionHouse.PostCommodity(item, duration, quantity, limit)
  callback:OnSellPending(itemId, limit)
end

function ns.Trading:RefreshBook(itemId, mumLevels, callback)
  if self._state ~= ns.TradingState.Idle then
    callback:OnBusy()
    return
  end

  self._state = ns.TradingState.BookRefreshPending
  self._itemId = itemId
  self._numLevels = mumLevels
  self._callback = callback
  
  local itemKey = C_AuctionHouse.MakeItemKey(itemId)
  C_AuctionHouse.SendSearchQuery(itemKey, {}, false)

  callback:OnBookRefreshPending(itemId)
end

function ns.Trading:RefreshSummary(itemIds, callback)
  if self._state ~= ns.TradingState.Idle then
    callback:OnBusy()
    return
  end

  self._state = ns.TradingState.SummaryRefreshPending
  self._callback = callback

  -- Create ItemKeys for supplied item IDs
  local itemKeys = {}
  for k=1, #itemIds do local itemId = itemIds[k];
    table.insert(itemKeys, C_AuctionHouse.MakeItemKey(itemId))
  end

  C_AuctionHouse.SearchForItemKeys(itemKeys, {})
  callback:OnSummaryRefreshPending(itemIds)
end

function ns.Trading:GetBook(itemId)
  local book = self._books[itemId]
  if book == nil then
    book = ns.OrderBook:New(itemId)
    self._books[itemId] = book
  end

  return book
end

--------------------------------------------------------------------------------
-- FRAME EVENT REGISTRATION
--------------------------------------------------------------------------------

ns.Trading._frame:SetScript("OnEvent", function (...)
  ns.Trading:_OnEvent(...)
end)

FrameUtil.RegisterFrameForEvents(ns.Trading._frame, {
  "COMMODITY_PRICE_UPDATED",
  "COMMODITY_PRICE_UNAVAILABLE",
  "COMMODITY_PURCHASE_FAILED",
  "COMMODITY_PURCHASE_SUCCEEDED",
  "AUCTION_HOUSE_AUCTION_CREATED",
  "COMMODITY_SEARCH_RESULTS_UPDATED",
  "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
  "AUCTION_HOUSE_SHOW_ERROR",
})

--------------------------------------------------------------------------------
-- ORDER BOOK
--------------------------------------------------------------------------------

ns.OrderBook = {
  _itemId = nil,

  _time = nil,
  _totalQuantity = nil,

  _length = 0,
  _price = {},
  _quantity = {},
}

function ns.OrderBook:New(itemId)
  local o = {
    _itemId = itemId
  }

  setmetatable(o, self)
  self.__index = self
  return o
end

function ns.OrderBook:GetItemId()
  return self._itemId
end

function ns.OrderBook:SetTotalQuantity(totalQuantity)
  self._totalQuantity = totalQuantity
end

function ns.OrderBook:GetTotalQuantity()
  return self._totalQuantity
end

function ns.OrderBook:SetTime(time)
  self._time = time
end

function ns.OrderBook:GetTime()
  return self._time
end

function ns.OrderBook:GetLength()
  return self._length
end

function ns.OrderBook:Clear()
  self._length = 0
  self._totalQuantity = nil
end

function ns.OrderBook:AddLevel(price, quantity)
  self._length = self._length + 1
  self._price[self._length] = price
  self._quantity[self._length] = quantity
end

function ns.OrderBook:GetLevel(i)
  if i <= 0 or i > self._length then
    return
  else
    return self:FastGetLevel(i)
  end
end
  
function ns.OrderBook:FastGetLevel(i)
  return self._price[i], self._quantity[i]
end


-- function Yours.Trading:CalcVwap(itemId, targetVolumes, result)
--   -- invariant: targetVolumes sorted asc

--   local book = self.itemBookData[itemId]
--   if book == nil then
--     return nil
--   end

--   local iTarget, iLevel = 1, 1
--   local remainingTargetVolume = targetVolumes[iTarget]

--   local cumVolume, cumPrice = 0, 0
--   while true do
--     local levelVolume = book.levelVolumes[iLevel]
--     local levelVolumeTake = math.min(levelVolume, remainingTargetVolume)
--     book.levelVolumes[iLevel] = levelVolume - levelVolumeTake

--     cumVolume = cumVolume + levelVolumeTake
--     cumPrice = cumPrice + levelVolumeTake * book.levelPrices[iLevel]

--     remainingTargetVolume = remainingTargetVolume - levelVolumeTake
--     if remainingTargetVolume == 0 then
--       result[iTarget] = cumPrice/cumVolume

--       iTarget = iTarget + 1
--       if iTarget > #targetVolumes then
--         break
--       end

--       remainingTargetVolume = targetVolumes[iTarget]
--     end

--     if book.levelVolumes[iLevel] == 0 then
--       iLevel = iLevel + 1
--     end

--     if iLevel > book.numLevels then
--       break
--     end
--   end

--   for i=iTarget,#targetVolumes do
--     result[i] = nil
--   end
-- end