local ShopSale = require("api/Entities/shop/ShopSale")
local ShopCollector = require("api/Entities/shop/ShopCollector")

local onPromoLoad = function(self, packet, connection, identifiers)
	if packet:readBool() then -- Sales
		self.event:emit("saleLoad", ShopSale:new(packet))
	else -- Collector
		self.event:emit("collectorLoad", ShopCollector:new(packet))
	end
end

return { onPromoLoad, 20, 03 }