_, Yours = ...

--------------------------------------------------------------------------------
-- BINDING TEXT
--------------------------------------------------------------------------------

BINDING_NAME_YOURS_BUY = "Yours: Buy"
BINDING_NAME_YOURS_SELL = "Yours: Sell"
BINDING_NAME_YOURS_TOGGLE_SHOW_WINDOWS = "Yours: Show/hide windows"
BINDING_NAME_YOURS_CLOSE_WINDOWS = "Yours: Close all windows"
BINDING_NAME_YOURS_CREATE_TRADING_WINDOW = "Yours: Create trading window"

--------------------------------------------------------------------------------
-- YOURS PARENT FRAME
--------------------------------------------------------------------------------

Yours.frame = CreateFrame("Frame", "YoursFrame", UIParent);
Yours.frame:SetAllPoints()

--------------------------------------------------------------------------------
-- SETTINGS
--------------------------------------------------------------------------------

function Yours.frame:OnEvent(event, arg1)
  if event == "ADDON_LOADED" and arg1 == "Yours" then
    YoursSettings = YoursSettings or {}
    YoursSettings.windows = YoursSettings.windows or {}
    YoursSettings.defaultCustoms = YoursSettings.defaultCustoms or {
      TRADING_WINDOW = {},
    }
  elseif event == "PLAYER_LOGOUT" then
    -- Clear windows: we want to overwrite it entirely
    YoursSettings.windows = {}

    for _, window in ipairs(Yours.windows) do
      local settings = window:GetSettings()
      local itemId = window:GetItemId()

      -- Write window settings
      table.insert(YoursSettings.windows, settings)

      -- Write default item ID custom window settings
      YoursSettings.defaultCustoms["TRADING_WINDOW"][itemId] = settings.custom
    end
  end
end

Yours.frame:RegisterEvent("ADDON_LOADED")
Yours.frame:RegisterEvent("PLAYER_LOGOUT")
Yours.frame:SetScript("OnEvent", Yours.frame.OnEvent);

--------------------------------------------------------------------------------
-- TRADING WINDOW
--------------------------------------------------------------------------------

Yours.windows = {}
Yours.activeWindow = nil
Yours.areWindowsLoaded = false
Yours.areWindowsShown = false

function Yours:CreateTradingWindow(settings)
  Yours:ShowWindows()

  -- Create window
  local window = Yours.Widgets.TradingWindow:New(Yours.frame, settings)
  table.insert(self.windows, window)

  -- Register callbacks
  window:RegisterOnSelect(function (window) self:SetActiveWindow(window) end)
  window:RegisterOnClose(function (window)
    table.remove(self.windows, Yours.Util:IndexOf(self.windows, window))
  end)
end

function Yours:SetActiveWindow(activeWindow)
  for _, window in ipairs(self.windows) do
      window:SetActive(window == activeWindow)
  end

  self.activeWindow = activeWindow
end

function Yours:Buy()
  if self.activeWindow == nil then
    return
  end

  self.activeWindow:Buy()
end

function Yours:Sell()
  if self.activeWindow == nil then
    return
  end

  self.activeWindow:Sell()
end

function Yours:CreateTradingWindowFromHover()
  local _, _, itemId = GameTooltip:GetItem()

  if itemId == nil then
    return
  end

  -- Load default window custom settings for item ID
  local custom = YoursSettings.defaultCustoms["TRADING_WINDOW"][itemId]

  -- No default for item ID
  if custom == nil then
    custom = {itemId = itemId}
  end

  self:CreateTradingWindow({
    type = "TRADING_WINDOW",
    custom = custom,
  })
end

function Yours:LoadWindows()
  -- Idempotency guard
  if Yours.areWindowsLoaded then
    return
  end
  Yours.areWindowsLoaded = true

  for _, settings in ipairs(YoursSettings.windows) do
    Yours:CreateTradingWindow(settings)
  end
end

function Yours:ShowWindows()
  Yours:LoadWindows() -- Idempotent

  self.areWindowsShown = true
  for _, window in ipairs(Yours.windows) do
    window:Show()
  end
end

function Yours:HideWindows()
  self.areWindowsShown = false
  for _, window in ipairs(Yours.windows) do
    window:Hide()
  end
end

function Yours:ToggleShowWindows()
  if self.areWindowsShown then
    self:HideWindows()
  else
    self:ShowWindows()
  end
end

function Yours:CloseWindows()
  -- Shallow copy of Yours.windows to iterate over when closing, as close
  -- modifies Yours.windows
  local open_windows = {}
  for _, window in ipairs(Yours.windows) do
    table.insert(open_windows, window)
  end

  -- Close all open windows
  for _, window in ipairs(open_windows) do
    window:Close()
  end
end