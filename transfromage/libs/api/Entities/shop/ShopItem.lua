------------------------------------------- Optimization -------------------------------------------
local math_floor    = math.floor
local setmetatable  = setmetatable
local string_format = string.format
----------------------------------------------------------------------------------------------------

local ShopItem = table.setNewClass("ShopItem")

local categoryPatch = {
	[00] = 010,
	[05] = 060,
	[22] = 230
}

ShopItem.new = function(self)
	return setmetatable({
		id = nil, -- id in the cat
		uniqueId = nil, -- unique id
		dressingId = nil, -- dressing id
		categoryId = nil, -- cat id

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
		isAvailableCollector = nil,

		isEquipped = nil, -- Based on the current outfit

		isOnSale = nil,
		fraisePriceWithDiscount = nil,
	}, self)
end

ShopItem.loadOwned = function(self, packet, categoryId, id, totalColors)
	if not categoryId then
		self.totalColors = packet:read8()

		local uniqueId = packet:read32()
		self.uniqueId = uniqueId

		if uniqueId > 9999 then
			self.categoryId = math_floor((uniqueId - 10000) / 10000)
		else
			self.categoryId = math_floor(uniqueId / 100)
		end

		if uniqueId < 99 then
			self.id = uniqueId
		elseif uniqueId < 999 then
			self.id = uniqueId % (100 * self.categoryId)
		elseif uniqueId < 9999 then
			self.id = uniqueId % 100
		else
			self.id = uniqueId % 1000
		end
	else
		self.uniqueId = categoryId * 1000 + id
		self.id = id
		self.categoryId = categoryId

		self.totalColors = totalColors
	end

	local patchedCategory
	if self.id > 99 then
		patchedCategory = categoryPatch[self.categoryId] or self.categoryId
	else
		patchedCategory = self.categoryId
	end
	self.dressingId = (patchedCategory .. string_format("%02d", self.id)) * 1

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
	local categoryId = packet:read16()
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

	if self.cheesePrice == 1000001 then
		self.isPurchasable = false
		self.cheesePrice = 0
	else
		self.isPurchasable = true
	end

	self.isCollector = self.flags == 13
	self.isAvailableCollector = not self.isCollector -- Becomes true in another packet

	return self:loadOwned(nil, categoryId, id, totalColors)
end

return ShopItem