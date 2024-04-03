_, ns = ...

ns.Widgets = ns.Widgets or {}

ns.Widgets.BookTile = {
  parent = nil,
  frame = nil,

  n_levels = nil,

  levels = nil,
}

--------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
--------------------------------------------------------------------------------

function ns.Widgets.BookTile:New(parent, n_levels)
  local o = {
    parent = parent,
    n_levels = n_levels,
  }
  setmetatable(o, self)
  self.__index = self

  o:_Init()

  return o
end

function ns.Widgets.BookTile:GetNumLevels()
  return self.n_levels
end

function ns.Widgets.BookTile:SetLevel(level, price, quantity, highlight)
    -- Gold/silver text
  local gold, silver, _ = ns.Util:MoneyParts(price)

  if gold < 10 then
    gold = "0"..gold
  end

  if silver < 10 then
    silver = "0"..silver
  end

  self.levels[level].priceGold:SetText(gold)
  self.levels[level].priceSilver:SetText(silver)
  self.levels[level].quantity:SetText(ns.Util:FormatThousands(quantity))

  if highlight then
    self.levels[level].background:SetColorTexture(29/255, 60/255, 54/255)
  else
    self.levels[level].background:SetColorTexture(26/255, 30/255, 38/255)
  end
end

--------------------------------------------------------------------------------
-- PRIVATE FUNCTIONS
--------------------------------------------------------------------------------

function ns.Widgets.BookTile:_Init()
  -- Containing frame
  self.frame = CreateFrame("Frame", nil, self.parent)
  self.frame:SetPoint("TOPLEFT")
  self.frame:SetPoint("TOPRIGHT")
  self.frame:SetSize(-1, 158)

  -- Levels
  self.levels = {}
  for i=1,self.n_levels do
    -- Frame
    local level = CreateFrame("Frame", nil, self.frame)
    level:SetPoint("TOPLEFT", 5, math.floor((i-1) * -25 - 5))
    level:SetPoint("TOPRIGHT", -5, 0)
    level:SetSize(-1, 22)

    -- Background
    local background = level:CreateTexture(nil, "ARTWORK")
    background:SetAllPoints()
    background:SetColorTexture(26/255, 30/255, 38/255)

    -- Price
    local _ = CreateFrame("Frame", nil, level)
    _:SetPoint("TOPLEFT", level, "TOPLEFT")
    _:SetPoint("BOTTOMRIGHT", level, "BOTTOM")

    local priceGold = _:CreateFontString()
    priceGold:SetPoint("BOTTOMRIGHT", _, "CENTER", -1, -7)
    priceGold:SetFont("Fonts\\ARIALN.ttf", 14, "")
    priceGold:SetTextColor(1, 1, 1)
    priceGold:SetJustifyH("RIGHT")
    priceGold:SetText("00")

    local priceSilver = _:CreateFontString()
    priceSilver:SetPoint("BOTTOMLEFT", _, "CENTER", 1, -7)
    priceSilver:SetFont("Fonts\\ARIALN.ttf", 10, "")
    priceSilver:SetTextColor(1, 1, 1, .7)
    priceSilver:SetJustifyH("LEFT")
    priceSilver:SetText("00")

    -- X separator
    local _ = level:CreateFontString()
    _:SetPoint("CENTER")
    _:SetFont("Fonts\\ARIALN.ttf", 10, "")
    _:SetTextColor(1, 1, 1, 0.5)
    _:SetJustifyH("CENTER")
    _:SetText("X")

    -- Quantity
    local quantity = CreateFrame("EditBox", nil, level)
    quantity:SetPoint("TOPRIGHT", -5, 0)
    quantity:SetPoint("BOTTOMRIGHT", -5, 0)
    quantity:SetSize(50, -1)
    quantity:SetFont("Fonts\\ARIALN.ttf", 12, "")
    quantity:SetTextColor(1, 1, 1)
    quantity:SetJustifyH("RIGHT")
    quantity:SetNumeric()
    quantity:SetAutoFocus(false)
    quantity:SetText(0)

    -- Insert
    self.levels[i] = {
      background = background,
      priceGold = priceGold,
      priceSilver = priceSilver,
      quantity = quantity,
    }
  end
end
