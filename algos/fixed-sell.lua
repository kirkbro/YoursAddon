_, ns = ...

ns.Algos = ns.Algos or {}

ns.Algos.FixedSell = {
  owner = nil,
  itemId = nil,
  quantity = nil,
  limit = nil,
}

--------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
--------------------------------------------------------------------------------

function ns.Algos.FixedSell:New()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function ns.Algos.FixedSell:IsIdle()
  return true
end

function ns.Algos.FixedSell:Configure(owner, itemId, quantity, limit)
  self.owner = owner
  self.itemId = itemId
  self.quantity = quantity
  self.limit = limit
end

function ns.Algos.FixedSell:Work()
  Yours.Trading:Sell(self.itemId, self.quantity, self.limit, 1, self)
end

--------------------------------------------------------------------------------
-- TRADING CALLBACKS
--------------------------------------------------------------------------------

function ns.Algos.FixedSell:OnBusy() end

function ns.Algos.FixedSell:OnLowInventory()
  self.owner:OnStatus("LOW INVENTORY")
end

function ns.Algos.FixedSell:OnSellPending(itemId, quotedPrice)
  self.owner:OnStatus("POSTING")
  self.owner:OnPrice(quotedPrice)
end

function ns.Algos.FixedSell:OnSellPosted(itemId, quotedPrice)
  self.owner:OnStatus("POSTED")
  self.owner:OnPrice(quotedPrice)
end

function ns.Algos.FixedSell:OnError()
  self.owner:OnStatus("ERROR")
end
