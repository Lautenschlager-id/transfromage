------------------------------------------- Optimization -------------------------------------------
local math_floor   = math.floor
local setmetatable = setmetatable
----------------------------------------------------------------------------------------------------

local ShopItem = table.setNewClass("ShopItem")

ShopItem.new = function(self)
	return setmetatable({
		uid = nil, -- rename, dressing id
		id = nil, -- rename, id in the category
		category = nil,

		totalColors = nil,
		colors = nil,

		cheesePrice = nil,
		fraisePrice = nil,

		isNew = nil,
		flags = nil,

		hasSpecialData = nil,
		specialData = nil,

		isPurchasable = nil,
		isCollector = nil,

		isEquiped = nil, -- Based on the current outfit
	}, self)
end

ShopItem.loadOwned = function(self, packet, category, id, totalColors)
	if not category then
		self.totalColors = packet:read8()

		uid = packet:read32()
		self.uid = uid

		self.category = uid > 9999 and math_floor((uid - 10000) / 10000) or math_floor(uid / 100)

		if uid < 99 then
			self.id = uid
		elseif uid < 999 then
			self.id = uid % (100 * self.category)
		elseif uid < 9999 then
			self.id = uid % 100
		else
			self.id = uid % 1000
		end
	else
		self.uid = category * 1000 + id
		self.id = id
		self.category = category

		self.totalColors = totalColors
	end

	if not totalColors and self.totalColors > 0 then -- Only owned items are gonna have this list
		local colors = { }
		self.colors = colors

		for c = 1, self.totalColors - 1 do
			colors[c] = packet:read32()
		end
	end

	return self
end

ShopItem.loadPurchasable = function(self, packet)
	local category = packet:read16()
	local id = packet:read16()
	local totalColors = packet:read8()

	self.isNew = packet:readBool()
	self.flags = packet:read8()

	self.cheesePrice = packet:read32()
	self.fraisePrice = packet:read32()

	self.hasSpecialData = packet:readBool()
	if self.hasSpecialData then
		self.specialData = packet:read32()
	end

	if self.cheesePrice ~= 1000001 then
		self.isPurchasable = true
		self.cheesePrice = 0
	end

	self.isCollector = self.flags == 13

	return self:loadOwned(nil, category, id, totalColors)
end

return ShopItem