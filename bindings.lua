_, Yours = ...

CreateFrame("Button", "YoursPlaceBidButton", nil, nil, nil)
YoursPlaceBidButton:SetScript("OnClick", function()
  Yours:PlaceBid()
end)

CreateFrame("Button", "YoursPlaceAskButton", nil, nil, nil)
YoursPlaceAskButton:SetScript("OnClick", function()
    Yours:PlaceAsk()
end)

CreateFrame("Button", "YoursCreateTileButton", nil, nil, nil)
YoursCreateTileButton:SetScript("OnClick", function()
  Yours:CreateTileFromHover()
end)
