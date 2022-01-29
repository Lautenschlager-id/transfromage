------------------------------------------- Optimization -------------------------------------------
local collectorList = require("api/Entities/shop/Shop").collector
local setmetatable  = setmetatable
----------------------------------------------------------------------------------------------------

local ShopCollector = table.setNewClass("ShopCollector")

ShopCollector.new = function(self, packet)
	local collector = setmetatable({
		isShamanItem = nil,

		itemId = nil, -- either dressingId (item) or uniqueId (shaman)

		timestamp = nil,

		discountPercentage = nil,
	}, self)

	collector.isShamanItem = not packet:readBool()
	collector.itemId = packet:read32()

	packet:readBool() -- ?

	collector.timestamp = packet:read32() * 1000

	collectorList[collector.itemId] = collector

	return collector
end

return ShopCollector