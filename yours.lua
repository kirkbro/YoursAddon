_, Yours = ...

-- Yours parent frame
Yours.frame = CreateFrame("Frame", "YoursFrame", UIParent);
Yours.frame:SetAllPoints()

function Yours.frame:OnEvent(event, ...)
  if event ~= "PLAYER_LOGOUT" then
    return
  end
  
  if YoursTileSettings == nil then
    YoursTileSettings = {}
  end

  for _, tile in ipairs(Yours.tiles) do
    YoursTileSettings[tile:GetItemId()] = {
      bidQuantity = tile:GetBidQuantity(),
      askQuantity = tile:GetAskQuantity(),
      bidLimit = tile:GetBidLimit(),
      askLimit = tile:GetAskLimit(),
    }
  end
end
Yours.frame:RegisterEvent("PLAYER_LOGOUT")
Yours.frame:SetScript("OnEvent", Yours.frame.OnEvent);

Yours.tiles = {}
Yours.activeTile = nil

function Yours:CreateTile(itemId)
  local tile = Yours.CommodityTile:Create(Yours.frame)
  tile:SetItemId(itemId)

  if YoursTileSettings ~= nil then
    local setting = YoursTileSettings[itemId]
    
    if setting ~= nil then
      tile:SetBidQuantity(setting["bidQuantity"])
      tile:SetAskQuantity(setting["askQuantity"])
      tile:SetBidLimit(setting["bidLimit"])
      tile:SetAskLimit(setting["askLimit"])
    end
  end

  table.insert(self.tiles, tile)
end

function Yours:SetActiveTile(activeTile)
  for _, tile in ipairs(self.tiles) do
      tile:SetActive(tile == activeTile)
  end

  self.activeTile = activeTile
end

function Yours:PlaceBid()
  if self.activeTile == nil then
    return
  end

  self.activeTile:PlaceBid()
end

function Yours:PlaceAsk()
  if self.activeTile == nil then
    return
  end

  self.activeTile:PlaceAsk()
end

function Yours:CreateTileFromHover()
  local _, _, itemId = GameTooltip:GetItem()
  
  if itemId == nil then
    return
  end

  self:CreateTile(itemId)
end
