------------------------------------------- Optimization -------------------------------------------
local setmetatable = setmetatable
----------------------------------------------------------------------------------------------------

local ShopShamanItem = table.setNewClass("ShopShamanItem")

ShopShamanItem.new = function(self)
	return setmetatable({
		uniqueId = nil,

		isEquipped = nil,

		totalColors = nil,
		colors = nil,

		cheesePrice = nil,
		fraisePrice = nil,

		isNew = nil,
		flags = nil,

		isOnSale = nil,
		fraisePriceWithDiscount = nil,
	}, self)
end

ShopShamanItem.loadOwned = function(self, packet)
	self.uniqueId = packet:read16()

	self.isEquipped = packet:readBool()

	self.totalColors = packet:read8()

	if self.totalColors > 0 then
		local colors = { }
		self.colors = colors

		for c = 1, self.totalColors - 1 do
			colors[c] = packet:read32()
		end
	end

	return self
end

ShopShamanItem.loadPurchasable = function(self, packet)
	self.uniqueId = packet:read32()
	self.totalColors = packet:read8()

	self.isNew = packet:readBool()
	self.flags = packet:read8()

	self.cheesePrice = packet:read32()
	self.fraisePrice = packet:read16()

	return self
end

return ShopShamanItem