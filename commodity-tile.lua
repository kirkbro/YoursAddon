_, Yours = ...

Yours.CommodityTile = {}

function Yours.CommodityTile:Create(parent)
  -- Header
  local frame = Mixin(CreateFrame("Button", nil, parent), Yours.CommodityTile)
  frame:SetPoint("CENTER")
  frame:SetSize(285, 30)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
  frame:RegisterForClicks("AnyUp");
  frame:SetScript("OnClick", function(...) Yours:SetActiveTile(frame) end);
  frame.titleTexture = frame:CreateTexture(nil, "BACKGROUND")
  frame.titleTexture:SetAllPoints()
  frame.titleTexture:SetColorTexture(.094, .094, .094)
  frame.titleIcon = frame:CreateTexture()
  frame.titleIcon:SetPoint("LEFT", 8, 0)
  frame.titleIcon:SetSize(18, 18)
  frame.titleText = frame:CreateFontString()
  frame.titleText:SetPoint("LEFT", 30, 0)
  frame.titleText:SetFont("Fonts\\ARIALN.ttf", 12)
  frame.titleText:SetTextColor(1, 1, 1)

  -- Dealing
  frame.dealingFrame = CreateFrame("Frame", nil, frame)
  frame.dealingFrame:SetPoint("TOPLEFT", frame, "BOTTOMLEFT")
  frame.dealingFrame:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT")
  frame.dealingFrame:SetSize(-1, 117)
  frame.dealingFrame.texture = frame.dealingFrame:CreateTexture(nil, "ARTWORK")
  frame.dealingFrame.texture:SetAllPoints()
  frame.dealingFrame.texture:SetColorTexture(.94, .94, .94)

  -- Dealing/Ask
  frame.dealingFrame.askFrame = CreateFrame("Button", nil, frame.dealingFrame)
  frame.dealingFrame.askFrame:SetPoint("TOPLEFT", 15, -10)
  frame.dealingFrame.askFrame:SetSize(124, 97)
  frame.dealingFrame.askFrame.texture = frame.dealingFrame.askFrame:CreateTexture()
  frame.dealingFrame.askFrame.texture:SetAllPoints()
  frame.dealingFrame.askFrame.texture:SetDrawLayer("BACKGROUND")
  frame.dealingFrame.askFrame.texture:SetColorTexture(.816, 0, .106)
  frame.dealingFrame.askFrame:RegisterForClicks("AnyUp");
  frame.dealingFrame.askFrame:SetScript("OnClick", function() frame:PlaceAsk() end);

  _ = frame.dealingFrame.askFrame:CreateFontString()
  _:SetPoint("TOPLEFT", 8, -12)
  _:SetFont("Fonts\\ARIALN.ttf", 9)
  _:SetTextColor(1, 1, 1, .8)
  _:SetText("SELL")

  frame.dealingFrame.askFrame.quantityInput = CreateFrame("EditBox", nil, frame.dealingFrame.askFrame)
  frame.dealingFrame.askFrame.quantityInput:SetPoint("TOPRIGHT", -8, -10)
  frame.dealingFrame.askFrame.quantityInput:SetSize(50, 9)
  frame.dealingFrame.askFrame.quantityInput:SetFont("Fonts\\ARIALN.ttf", 12, "")
  frame.dealingFrame.askFrame.quantityInput:SetTextColor(1, 1, 1)
  frame.dealingFrame.askFrame.quantityInput:SetJustifyH("RIGHT")
  frame.dealingFrame.askFrame.quantityInput:SetNumeric()
  frame.dealingFrame.askFrame.quantityInput:SetAutoFocus(false)

  _ = frame.dealingFrame.askFrame:CreateTexture()
  _:SetPoint("TOPLEFT", 0, -28)
  _:SetPoint("TOPRIGHT", 0, -28)
  _:SetSize(-1, 1)
  _:SetDrawLayer("BORDER")
  _:SetColorTexture(1, 1, 1, .5)

  _ = frame.dealingFrame.askFrame:CreateFontString()
  _:SetPoint("TOPLEFT", 8, -34)
  _:SetFont("Fonts\\ARIALN.ttf", 8)
  _:SetTextColor(1, 1, 1, .8)
  _:SetText("LIMIT")

  frame.dealingFrame.askFrame.limitInput = CreateFrame("EditBox", nil, frame.dealingFrame.askFrame)
  frame.dealingFrame.askFrame.limitInput:SetPoint("TOPRIGHT", -8, -34)
  frame.dealingFrame.askFrame.limitInput:SetSize(50, 10)
  frame.dealingFrame.askFrame.limitInput:SetFont("Fonts\\ARIALN.ttf", 10, "")
  frame.dealingFrame.askFrame.limitInput:SetTextColor(1, 1, 1)
  frame.dealingFrame.askFrame.limitInput:SetJustifyH("RIGHT")
  frame.dealingFrame.askFrame.limitInput:SetNumeric()
  frame.dealingFrame.askFrame.limitInput:SetAutoFocus(false)

  frame.dealingFrame.askFrame.priceGoldText = frame.dealingFrame.askFrame:CreateFontString()
  frame.dealingFrame.askFrame.priceGoldText:SetPoint("BOTTOMLEFT", frame.dealingFrame.askFrame, "TOPLEFT", -1, -75)
  frame.dealingFrame.askFrame.priceGoldText:SetPoint("BOTTOMRIGHT", frame.dealingFrame.askFrame, "TOP", -1, -75)
  frame.dealingFrame.askFrame.priceGoldText:SetFont("Fonts\\ARIALN.ttf", 22, "")
  frame.dealingFrame.askFrame.priceGoldText:SetTextColor(1, 1, 1)
  frame.dealingFrame.askFrame.priceGoldText:SetJustifyH("RIGHT")

  frame.dealingFrame.askFrame.priceSilverText = frame.dealingFrame.askFrame:CreateFontString()
  frame.dealingFrame.askFrame.priceSilverText:SetPoint("BOTTOMRIGHT", frame.dealingFrame.askFrame, "TOPRIGHT", 1, -75)
  frame.dealingFrame.askFrame.priceSilverText:SetPoint("BOTTOMLEFT", frame.dealingFrame.askFrame, "TOP", 1, -75)
  frame.dealingFrame.askFrame.priceSilverText:SetFont("Fonts\\ARIALN.ttf", 16, "")
  frame.dealingFrame.askFrame.priceSilverText:SetTextColor(1, 1, 1, .7)
  frame.dealingFrame.askFrame.priceSilverText:SetJustifyH("LEFT")

  _ = frame.dealingFrame.askFrame:CreateTexture()
  _:SetPoint("TOPLEFT", 0, -80)
  _:SetPoint("TOPRIGHT", 0, -80)
  _:SetSize(-1, 1)
  _:SetDrawLayer("BORDER")
  _:SetColorTexture(1, 1, 1, .5)

  frame.dealingFrame.askFrame.statusText = frame.dealingFrame.askFrame:CreateFontString()
  frame.dealingFrame.askFrame.statusText:SetPoint("BOTTOM", 0, 4)
  frame.dealingFrame.askFrame.statusText:SetFont("Fonts\\ARIALN.ttf", 8, "")
  frame.dealingFrame.askFrame.statusText:SetTextColor(1, 1, 1, .8)
  frame.dealingFrame.askFrame.statusText:SetText("-")

  -- Dealing/Bid
  frame.dealingFrame.bidFrame = CreateFrame("Button", nil, frame.dealingFrame)
  frame.dealingFrame.bidFrame:SetPoint("TOPRIGHT", -15, -10)
  frame.dealingFrame.bidFrame:SetSize(124, 97)
  frame.dealingFrame.bidFrame.texture = frame.dealingFrame.bidFrame:CreateTexture()
  frame.dealingFrame.bidFrame.texture:SetAllPoints()
  frame.dealingFrame.bidFrame.texture:SetDrawLayer("BACKGROUND")
  frame.dealingFrame.bidFrame.texture:SetColorTexture(0.290, 0.565, 0.886)
  frame.dealingFrame.bidFrame:RegisterForClicks("AnyUp");
  frame.dealingFrame.bidFrame:SetScript("OnClick", function() frame:PlaceBid() end);

  _ = frame.dealingFrame.bidFrame:CreateFontString()
  _:SetPoint("TOPRIGHT", -8, -12)
  _:SetFont("Fonts\\ARIALN.ttf", 9)
  _:SetTextColor(1, 1, 1, .8)
  _:SetText("BUY")

  frame.dealingFrame.bidFrame.quantityInput = CreateFrame("EditBox", nil, frame.dealingFrame.bidFrame)
  frame.dealingFrame.bidFrame.quantityInput:SetPoint("TOPLEFT", 8, -10)
  frame.dealingFrame.bidFrame.quantityInput:SetSize(50, 9)
  frame.dealingFrame.bidFrame.quantityInput:SetFont("Fonts\\ARIALN.ttf", 12, "")
  frame.dealingFrame.bidFrame.quantityInput:SetTextColor(1, 1, 1)
  frame.dealingFrame.bidFrame.quantityInput:SetJustifyH("LEFT")
  frame.dealingFrame.bidFrame.quantityInput:SetNumeric()
  frame.dealingFrame.bidFrame.quantityInput:SetAutoFocus(false)

  _ = frame.dealingFrame.bidFrame:CreateTexture()
  _:SetPoint("TOPLEFT", 0, -28)
  _:SetPoint("TOPRIGHT", 0, -28)
  _:SetSize(-1, 1)
  _:SetDrawLayer("BORDER")
  _:SetColorTexture(1, 1, 1, .5)

  _ = frame.dealingFrame.bidFrame:CreateFontString()
  _:SetPoint("TOPRIGHT", -8, -34)
  _:SetFont("Fonts\\ARIALN.ttf", 8)
  _:SetTextColor(1, 1, 1, .8)
  _:SetText("LIMIT")

  frame.dealingFrame.bidFrame.limitInput = CreateFrame("EditBox", nil, frame.dealingFrame.bidFrame)
  frame.dealingFrame.bidFrame.limitInput:SetPoint("TOPLEFT", 8, -34)
  frame.dealingFrame.bidFrame.limitInput:SetSize(50, 10)
  frame.dealingFrame.bidFrame.limitInput:SetFont("Fonts\\ARIALN.ttf", 10, "")
  frame.dealingFrame.bidFrame.limitInput:SetTextColor(1, 1, 1)
  frame.dealingFrame.bidFrame.limitInput:SetJustifyH("LEFT")
  frame.dealingFrame.bidFrame.limitInput:SetNumeric()
  frame.dealingFrame.bidFrame.limitInput:SetAutoFocus(false)

  frame.dealingFrame.bidFrame.priceGoldText = frame.dealingFrame.bidFrame:CreateFontString()
  frame.dealingFrame.bidFrame.priceGoldText:SetPoint("BOTTOMLEFT", frame.dealingFrame.bidFrame, "TOPLEFT", -1, -75)
  frame.dealingFrame.bidFrame.priceGoldText:SetPoint("BOTTOMRIGHT", frame.dealingFrame.bidFrame, "TOP", -1, -75)
  frame.dealingFrame.bidFrame.priceGoldText:SetFont("Fonts\\ARIALN.ttf", 22, "")
  frame.dealingFrame.bidFrame.priceGoldText:SetTextColor(1, 1, 1)
  frame.dealingFrame.bidFrame.priceGoldText:SetJustifyH("RIGHT")

  frame.dealingFrame.bidFrame.priceSilverText = frame.dealingFrame.bidFrame:CreateFontString()
  frame.dealingFrame.bidFrame.priceSilverText:SetPoint("BOTTOMRIGHT", frame.dealingFrame.bidFrame, "TOPRIGHT", 1, -75)
  frame.dealingFrame.bidFrame.priceSilverText:SetPoint("BOTTOMLEFT", frame.dealingFrame.bidFrame, "TOP", 1, -75)
  frame.dealingFrame.bidFrame.priceSilverText:SetFont("Fonts\\ARIALN.ttf", 16, "")
  frame.dealingFrame.bidFrame.priceSilverText:SetTextColor(1, 1, 1, .7)
  frame.dealingFrame.bidFrame.priceSilverText:SetJustifyH("LEFT")

  _ = frame.dealingFrame.bidFrame:CreateTexture()
  _:SetPoint("TOPLEFT", 0, -80)
  _:SetPoint("TOPRIGHT", 0, -80)
  _:SetSize(-1, 1)
  _:SetDrawLayer("BORDER")
  _:SetColorTexture(1, 1, 1, .5)

  frame.dealingFrame.bidFrame.statusText = frame.dealingFrame.bidFrame:CreateFontString()
  frame.dealingFrame.bidFrame.statusText:SetPoint("BOTTOM", 0, 4)
  frame.dealingFrame.bidFrame.statusText:SetFont("Fonts\\ARIALN.ttf", 8, "")
  frame.dealingFrame.bidFrame.statusText:SetTextColor(1, 1, 1, .8)
  frame.dealingFrame.bidFrame.statusText:SetText("-")

  frame:SetBidQuantity(10)
  frame:SetAskQuantity(1)
  frame:SetBidLimit(0)
  frame:SetAskLimit(0)
  frame:SetBidPrice(0)
  frame:SetAskPrice(0)

  Yours.Trading:RegisterListener(function(...) frame:OnTradingEvent(...) end)

  return frame
end

function Yours.CommodityTile:GetItemId()
  return self.itemId
end

function Yours.CommodityTile:SetItemId(itemId)
  local itemName, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemId)

  self.titleText:SetText(itemName:upper())
  self.titleIcon:SetTexture(itemTexture)
  self.itemId = itemId
end

function Yours.CommodityTile:GetBidQuantity()
  return self.dealingFrame.bidFrame.quantityInput:GetNumber()
end

function Yours.CommodityTile:SetBidQuantity(quantity)
  self.dealingFrame.bidFrame.quantityInput:SetText(quantity)
end

function Yours.CommodityTile:GetAskQuantity()
  return self.dealingFrame.askFrame.quantityInput:GetNumber()
end

function Yours.CommodityTile:SetAskQuantity(quantity)
  self.dealingFrame.askFrame.quantityInput:SetText(quantity)
end

function Yours.CommodityTile:GetBidLimit()
  return self.dealingFrame.bidFrame.limitInput:GetNumber() * 100
end

function Yours.CommodityTile:SetBidLimit(limit)
  self.dealingFrame.bidFrame.limitInput:SetText(limit / 100)
end

function Yours.CommodityTile:GetAskLimit()
  return self.dealingFrame.askFrame.limitInput:GetNumber() * 100
end

function Yours.CommodityTile:SetAskLimit(limit)
  self.dealingFrame.askFrame.limitInput:SetText(limit / 100)
end

local function GetGoldIn(copper)
  return math.floor(copper / 10000)
end

local function GetSilverIn(copper)
  return math.floor(copper % 10000 / 100)
end

function Yours.CommodityTile:SetBidPrice(price)
  local gold = tostring(GetGoldIn(price))
  if #gold == 1 then
    gold = "0"..gold
  end

  local silver = tostring(GetSilverIn(price))
  if #silver == 1 then
    silver = "0"..silver
  end

  self.dealingFrame.bidFrame.priceGoldText:SetText(gold)
  self.dealingFrame.bidFrame.priceSilverText:SetText(silver)
end

function Yours.CommodityTile:SetAskPrice(price)
  local gold = tostring(GetGoldIn(price))
  if #gold == 1 then
    gold = "0"..gold
  end

  local silver = tostring(GetSilverIn(price))
  if #silver == 1 then
    silver = "0"..silver
  end

  self.dealingFrame.askFrame.priceGoldText:SetText(gold)
  self.dealingFrame.askFrame.priceSilverText:SetText(silver)
end

function Yours.CommodityTile:SetBidStatus(status)
  self.dealingFrame.bidFrame.statusText:SetText(status)
end

function Yours.CommodityTile:SetAskStatus(status)
  self.dealingFrame.askFrame.statusText:SetText(status)
end

function Yours.CommodityTile:SetActive(active)
  if active then
    self.titleTexture:SetColorTexture(0.145, 0.278, 0.145)
  else
    self.titleTexture:SetColorTexture(.094, .094, .094)
  end
end

function Yours.CommodityTile:PlaceBid()
  local quantity = self:GetBidQuantity()
  local limit = self:GetBidLimit()

  Yours.Trading:PlaceBid(self, self.itemId, quantity, limit)
end

function Yours.CommodityTile:OnTradingEvent(event, ...)
  if event == "BID_STATE_UPDATE" then
    local owner, state, quote = ...
    
    if owner ~= self then
      return
    end

    if quote ~= nil then
      self:SetBidPrice(quote)
    end

    if state == Yours.Trading.BidState.WaitingForQuote then
      self:SetBidStatus("WAITING")
    elseif state == Yours.Trading.BidState.QuoteUnavailable then
      self:SetBidStatus("NO MARKET")
    elseif state == Yours.Trading.BidState.QuoteDealerIntervention then
      self:SetBidStatus("INTERVENTION")
    elseif state == Yours.Trading.BidState.QuotePassed then
      self:SetBidStatus("PASS")
    elseif state == Yours.Trading.BidState.QuoteLifted then
      self:SetBidStatus("LIFTED")
    elseif state == Yours.Trading.BidState.TradeFilled then
      self:SetBidStatus("FILLED")
    elseif state == Yours.Trading.BidState.TradeRejected then
      self:SetBidStatus("REJECTED")
    end
  end
end