local ShopSale = require("api/Entities/shop/ShopSale")

local onShopSalesLoad = function(self, packet, connection, identifiers)
	if not packet:readBool() then return end -- Collector item

	self.event:emit("saleLoad", ShopSale:new(packet))
end

return { onShopSalesLoad, 20, 03 }