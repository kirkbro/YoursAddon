_, Yours = ...

Yours.Trading = CreateFrame("Frame")

Yours.Trading.BidState = EnumUtil.MakeEnum(
  "WaitingForQuote",
  "QuoteUnavailable",
  "QuoteDealerIntervention",
  "QuotePassed",
  "QuoteLifted",
  "TradeFilled",
  "TradeRejected"
)

Yours.Trading.AskState = EnumUtil.MakeEnum(
  "PlacingOrder",
  "OrderAccepted",
  "OrderRejected"
)

Yours.Trading.SystemState = EnumUtil.MakeEnum(
  "Idle",
  "WorkingBid",
  "WorkingAsk"
)

function Yours.Trading:OnEvent(event, ...)
  -- WorkingBid
  if self.state == Yours.Trading.SystemState.WorkingBid then
    if self.bidState == Yours.Trading.BidState.WaitingForQuote then
      if event == "COMMODITY_PRICE_UPDATED" then
        self.bidQuote = ...

        if self.bidLimit > 0 then
          if self.bidQuote <= self.bidLimit then
            print("Confirming ", self.bidItemId, self.bidQuantity)
            C_AuctionHouse.ConfirmCommoditiesPurchase(self.bidItemId, self.bidQuantity)
            self:UpdateBidState(Yours.Trading.BidState.QuoteLifted)
          else
            self:UpdateBidState(Yours.Trading.BidState.QuotePassed)
            self.state = Yours.Trading.SystemState.Idle
          end
        else
          self:UpdateBidState(Yours.Trading.BidState.QuoteDealerIntervention)
          self.state = Yours.Trading.SystemState.Idle -- TODO: Not quite right
        end
      elseif event == "COMMODITY_PRICE_UNAVAILABLE" then
        self:UpdateBidState(Yours.Trading.BidState.QuoteUnavailable)
        self.state = Yours.Trading.SystemState.Idle
      end
    elseif self.bidState == Yours.Trading.BidState.QuoteLifted then
      if event == "COMMODITY_PURCHASE_SUCCEEDED" then
        self:UpdateBidState(Yours.Trading.BidState.TradeFilled)
        self.state = Yours.Trading.SystemState.Idle
      elseif event == "COMMODITY_PURCHASE_FAILED" then
        self:UpdateBidState(Yours.Trading.BidState.TradeRejected)
        self.state = Yours.Trading.SystemState.Idle
      end
    end

  -- WorkingAsk
  elseif self.state == Yours.Trading.SystemState.WorkingAsk then

  end
end

function Yours.Trading:RegisterListener(listener)
  table.insert(self.listeners, listener)
end

function Yours.Trading:FireBidStateUpdate()
  for _, listener in ipairs(self.listeners) do
      listener("BID_STATE_UPDATE", self.bidOwner, self.bidState, self.bidQuote)
  end
end

function Yours.Trading:GetState()
  return self.state
end

function Yours.Trading:UpdateBidState(bidState)
  self.bidState = bidState
  self:FireBidStateUpdate()
end

function Yours.Trading:PlaceBid(owner, itemId, quantity, limit)
  if self.state ~= Yours.Trading.SystemState.Idle then
    return
  end

  C_AuctionHouse.StartCommoditiesPurchase(itemId, quantity)

  self.bidOwner = owner
  self.bidItemId = itemId
  self.bidQuantity = quantity
  self.bidLimit = limit
  self.bidQuote = nil
  self.state = Yours.Trading.SystemState.WorkingBid

  self:UpdateBidState(Yours.Trading.BidState.WaitingForQuote)
end

--------------------
-- INITIALIZATION --
--------------------

Yours.Trading.listeners = {}
Yours.Trading.state = Yours.Trading.SystemState.Idle
Yours.Trading.bidOwner = nil
Yours.Trading.bidState = nil
Yours.Trading.bidItemId = nil
Yours.Trading.bidQuantity = nil
Yours.Trading.bidLimit = nil
Yours.Trading.bidQuote = nil
Yours.Trading.askState = nil

Yours.Trading:SetScript("OnEvent", Yours.Trading.OnEvent)

FrameUtil.RegisterFrameForEvents(Yours.Trading, {
  "COMMODITY_PRICE_UPDATED",
  "COMMODITY_PRICE_UNAVAILABLE",
  "COMMODITY_PURCHASE_FAILED",
  "COMMODITY_PURCHASE_SUCCEEDED",
})
