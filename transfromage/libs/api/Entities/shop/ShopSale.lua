------------------------------------------- Optimization -------------------------------------------
local salesList    = require("api/Entities/shop/Shop").sales
local setmetatable = setmetatable
----------------------------------------------------------------------------------------------------

local ShopSale = table.setNewClass("ShopSale")

ShopSale.new = function(self, packet)
	local sale = setmetatable({
		isShamanItem = nil,

		uid = nil,

		timestamp = nil,

		discountPercentage = nil,
	}, self)

	sale.isShamanItem = not packet:readBool()
	sale.uid = packet:read32()

	packet:readBool() -- ?

	sale.timestamp = packet:read32() * 1000
	sale.discountPercentage = packet:read8()

	salesList[sale.uid] = sale

	return sale
end

return ShopSale