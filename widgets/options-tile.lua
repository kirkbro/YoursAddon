_, ns = ...

ns.Widgets = ns.Widgets or {}

ns.Widgets.OptionsTile = {
  parent = nil,
  frame = nil,

  optionInputs = nil,
}

--------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
--------------------------------------------------------------------------------

function ns.Widgets.OptionsTile:New(parent, options)
  local o = {
    parent = parent,
    options = options,
  }
  setmetatable(o, self)
  self.__index = self

  o:_Init()

  return o
end

function ns.Widgets.OptionsTile:GetOption(option)
  return self.optionInputs[option]:GetNumber()
end

function ns.Widgets.OptionsTile:SetOption(option, value)
  self.optionInputs[option]:SetText(value)
end

--------------------------------------------------------------------------------
-- PRIVATE FUNCTIONS
--------------------------------------------------------------------------------

function ns.Widgets.OptionsTile:_Init()
  -- Containing frame
  self.frame = CreateFrame("Frame", nil, self.parent)
  self.frame:SetPoint("TOPLEFT")
  self.frame:SetPoint("TOPRIGHT")
  self.frame:SetSize(-1, 158)

  self.optionInputs = {}
  for i, option in ipairs(self.options) do
    -- Frame
    local optionFrame = CreateFrame("Frame", nil, self.frame)
    local yOffset = (i - 1) * -35
    optionFrame:SetPoint("TOPLEFT", 5, -5 + yOffset)
    optionFrame:SetPoint("TOPRIGHT", -5, -5 + yOffset)
    optionFrame:SetSize(-1, 30)

    -- Background
    local _ = optionFrame:CreateTexture(nil, "ARTWORK")
    _:SetAllPoints()
    _:SetColorTexture(26/255, 30/255, 38/255)

    -- Title
    local _ = optionFrame:CreateFontString()
    _:SetPoint("TOPLEFT", 5, -2)
    _:SetPoint("BOTTOMRIGHT", optionFrame, "TOPRIGHT", 5, -10)
    _:SetFont("Fonts\\ARIALN.ttf", 8, "")
    _:SetTextColor(1, 1, 1, 0.5)
    _:SetJustifyH("LEFT")
    _:SetText(option)

    -- Input
    local input = CreateFrame("EditBox", nil, optionFrame)
    input:SetPoint("BOTTOMLEFT", 5, 4)
    input:SetPoint("TOPRIGHT", -5, -10)
    input:SetSize(-1, -1)
    input:SetFont("Fonts\\ARIALN.ttf", 10, "")
    input:SetTextColor(1, 1, 1)
    input:SetJustifyH("LEFT")
    input:SetNumeric()
    input:SetAutoFocus(false)
    input:SetText(5)

    self.optionInputs[option] = input
  end
end
