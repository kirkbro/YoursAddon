_, ns = ...

ns.Algos = ns.Algos or {}

local State = EnumUtil.MakeEnum(
  "RequestBook",
  "RequestQuote"
)

ns.Algos.DynamicBuy = {
  owner = nil,
  itemId = nil,
  minQuantity = nil,
  maxQuantity = nil,
  sweepFactor = nil,
  maxLevels = nil,
  limit = nil,

  targetQuantity = nil,
  state = State.RequestBook,
}

--------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
--------------------------------------------------------------------------------

function ns.Algos.DynamicBuy:New()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function ns.Algos.DynamicBuy:IsIdle()
  return self.state == State.RequestBook
end

function ns.Algos.DynamicBuy:Configure(
  owner, itemId, minQuantity, maxQuantity, sweepFactor, maxLevels, limit)

  self.owner = owner
  self.itemId = itemId
  self.minQuantity = minQuantity
  self.maxQuantity = maxQuantity
  self.sweepFactor = sweepFactor
  self.maxLevels = maxLevels
  self.limit = limit
  self.state = State.RequestBook
end

function ns.Algos.DynamicBuy:Work()
  if self.state == State.RequestBook then
    Yours.Trading:RefreshBook(self.itemId, self.maxLevels, self)
  elseif self.state == State.RequestQuote then
    Yours.Trading:Buy(self.itemId, self.targetQuantity, self.limit, self)
  end
end

--------------------------------------------------------------------------------
-- TRADING CALLBACKS
--------------------------------------------------------------------------------

function ns.Algos.DynamicBuy:OnBusy() end

function ns.Algos.DynamicBuy:OnBookRefreshPending()
  self.owner:OnStatus("REQUESTING BOOK")
end

function ns.Algos.DynamicBuy:OnBookRefreshed(itemId)
  if itemId ~= self.itemId then return end

  -- Calculate quantity below limit
  local targetQuantity = 0
  local book = Yours.Trading:GetBook(self.itemId)
  for i=1, book:GetLength() do
    local price, quantity = book:FastGetLevel(i)

    -- No more levels <= limit
    if price > self.limit then
      break
    end

    targetQuantity = targetQuantity + quantity
  end

  -- Apply sweep factor
  targetQuantity = math.floor(targetQuantity * self.sweepFactor)

  -- Apply max quantity
  targetQuantity = math.min(targetQuantity, self.maxQuantity)

  -- Switch on target quantity
  if targetQuantity >= self.minQuantity then
    -- Above minimum quantity: next step should request quote
    self.state = State.RequestQuote
    self.targetQuantity = targetQuantity
    self.owner:OnStatus("FOUND x "..targetQuantity)
  elseif targetQuantity > 0 then
    -- Below minimum but non-zero quantity below limit
    self.owner:OnStatus("PASS BOOK x "..targetQuantity)
  else
    -- Zero quantity below limit
    self.owner:OnStatus("PASS BOOK")
  end

  -- Output TOB
  if book:GetLength() > 0 then
    local price, _ = book:FastGetLevel(1)
    self.owner:OnPrice(price)
  end

  -- Output FOB
  self.owner:OnBook(book)
end

function ns.Algos.DynamicBuy:OnQuoteRequested()
  self.owner:OnStatus("REQUESTING")
end

function ns.Algos.DynamicBuy:OnQuoteAccepted(itemId, quotedPrice)
  self.owner:OnStatus("LIFTING")
  self.owner:OnPrice(quotedPrice)
end

function ns.Algos.DynamicBuy:OnQuotePassed(itemId, quotedPrice)
  self.owner:OnStatus("PASS")
  self.owner:OnPrice(quotedPrice)
  self.state = State.RequestBook
end

function ns.Algos.DynamicBuy:OnQuoteUnavailable()
  self.owner:OnStatus("UNAVAILABLE")
  self.state = State.RequestBook
end

function ns.Algos.DynamicBuy:OnTradeRejected()
  self.owner:OnStatus("REJECTED")
  self.state = State.RequestBook
end

function ns.Algos.DynamicBuy:OnTradeFilled()
  self.owner:OnStatus("FILLED")
  self.state = State.RequestBook
end

function ns.Algos.DynamicBuy:OnError()
  self.owner:OnStatus("ERROR")
  self.state = State.RequestBook
end
