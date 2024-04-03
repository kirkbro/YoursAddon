_, ns = ...

ns.Algos = ns.Algos or {}

ns.Algos.FixedBuy = {
  owner = nil,
  itemId = nil,
  quantity = nil,
  limit = nil,
}

--------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
--------------------------------------------------------------------------------

function ns.Algos.FixedBuy:New()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function ns.Algos.FixedBuy:IsIdle()
  return true
end

function ns.Algos.FixedBuy:Configure(owner, itemId, quantity, limit)
  self.owner = owner
  self.itemId = itemId
  self.quantity = quantity
  self.limit = limit
end

function ns.Algos.FixedBuy:Work()
  Yours.Trading:Buy(self.itemId, self.quantity, self.limit, self)
end

--------------------------------------------------------------------------------
-- TRADING CALLBACKS
--------------------------------------------------------------------------------

function ns.Algos.FixedBuy:OnBusy() end

function ns.Algos.FixedBuy:OnQuoteRequested()
  self.owner:OnStatus("REQUESTING")
end

function ns.Algos.FixedBuy:OnQuoteAccepted(itemId, quotedPrice)
  self.owner:OnStatus("LIFTING")
  self.owner:OnPrice(quotedPrice)
end

function ns.Algos.FixedBuy:OnQuotePassed(itemId, quotedPrice)
  self.owner:OnStatus("PASS")
  self.owner:OnPrice(quotedPrice)
end

function ns.Algos.FixedBuy:OnQuoteUnavailable()
  self.owner:OnStatus("UNAVAILABLE")
end

function ns.Algos.FixedBuy:OnTradeRejected()
  self.owner:OnStatus("REJECTED")
end

function ns.Algos.FixedBuy:OnTradeFilled()
  self.owner:OnStatus("FILLED")
end

function ns.Algos.FixedBuy:OnError()
  self.owner:OnStatus("ERROR")
end
