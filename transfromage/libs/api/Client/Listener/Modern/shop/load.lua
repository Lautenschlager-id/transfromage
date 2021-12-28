local onShopLoad = function(self, packet, connection, identifiers)
	self.shop:load(packet)
	self.event:emit("shopLoad", self.shop)
end

return { onShopLoad, 8, 20 }