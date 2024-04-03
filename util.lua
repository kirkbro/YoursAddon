_, ns = ...

ns.Util = {}

--------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
--------------------------------------------------------------------------------

function ns.Util:MoneyParts(copper)
  return math.floor(copper / 10000),
         math.floor(copper % 10000 / 100),
         copper % 10000
end

function ns.Util:IndexOf(array, value)
  for i, v in ipairs(array) do
    if v == value then
      return i
    end
  end
  return nil
end

function ns.Util:FormatThousands(value)
  return tostring(value):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end