local ShopItem = require("api/Entities/shop/ShopItem")
local ShopShamanItem = require("api/Entities/shop/ShopShamanItem")

local Outfit = require("api/Entities/player/Outfit")

------------------------------------------- Optimization -------------------------------------------
local math_ceil    = math.ceil
local setmetatable = setmetatable
local string_sub   = string.sub
local table_copy   = table.copy
----------------------------------------------------------------------------------------------------

local Shop = table.setNewClass("Shop")

Shop.sales = { }
Shop.collector = { }

Shop.new = function(self)
	return setmetatable({
		totalCheese = nil,
		totalFraise = nil,

		currentOutfit = nil,

		item = {
			category = {
				-- [id]
			},
			shaman = {
				-- [uniqueId]
			},
			byUniqueId = {
				-- [uniqueId]
			},
			byDressingId = {
				-- [dressingId]
			}
		},

		ownedItems = { },
		purchasableItems = { },

		ownedShamanItems = { },
		purchasableShamanItems = { },

		fashionSquadOutfits = { },
		ownedOutfits = { }
	}, self)
end

local insertItem = function(self, item)
	local itemList = self.item

	if not itemList.category[item.categoryId] then
		itemList.category[item.categoryId] = { }
	end
	itemList.category[item.categoryId][item.id] = item

	itemList.byUniqueId[item.uniqueId] = item

	itemList.byDressingId[item.dressingId] = item
end

local checkItemSale = function(self, item)
	local sale = self.sales[item.dressingId or item.uniqueId]
	if not sale then return end
	if not sale.isShamanItem and not item.id then return end

	item.isOnSale = true

	if not item.fraisePrice then return end
	item.fraisePriceWithDiscount = math_ceil(item.fraisePrice -
		(item.fraisePrice * (sale.discountPercentage / 100)))
end

local checkItemCollector = function(self, item)
	local collector = self.collector[item.dressingId or item.uniqueId]
	if not collector then return end
	if not collector.isShamanItem and not item.id then return end

	item.isAvailableCollector = true
end

Shop.load = function(self, packet)
	self.totalCheese = packet:read32()
	self.totalFraise = packet:read32()

	self.currentOutfit = Outfit:new():load(packet)

	-- Owned items
	local tmpItem
	for i = 1, packet:read32() do
		tmpItem = ShopItem:new():loadOwned(packet)

		self.ownedItems[i] = tmpItem
		insertItem(self, tmpItem)
		checkItemSale(self, tmpItem)
		checkItemCollector(self, tmpItem)
	end

	-- Available items in the shop that haven't been purchased yet
	for i = 1, packet:read32() do
		tmpItem = ShopItem:new():loadPurchasable(packet)
		self.purchasableItems[i] = tmpItem
		insertItem(self, tmpItem)
		checkItemSale(self, tmpItem)
		checkItemCollector(self, tmpItem)
	end

	-- Currently available FS outfits
	for i = 1, packet:read8() do
		self.fashionSquadOutfits[i] = Outfit:new():loadFromFashion(packet)
	end

	-- Outfits the account currently owns
	for i = 1, packet:read16() do
		self.ownedOutfits[i] = Outfit:new():load(packet, i)
	end

	local shamanItemList = self.item.shaman
	-- Owned shaman items
	for i = 1, packet:read16() do
		tmpItem = ShopShamanItem:new():loadOwned(packet)

		self.ownedShamanItems[i] = tmpItem
		shamanItemList[tmpItem.uniqueId] = tmpItem
		checkItemSale(self, tmpItem)
		checkItemCollector(self, tmpItem)
	end

	-- Available shaman items in the shop that haven't been purchased yet
	for i = 1, packet:read16() do
		tmpItem = ShopShamanItem:new():loadPurchasable(packet)

		self.purchasableShamanItems[i] = tmpItem
		shamanItemList[tmpItem.uniqueId] = tmpItem
		checkItemSale(self, tmpItem)
		checkItemCollector(self, tmpItem)
	end
end

Shop.getItem = function(self, categoryId, id)
	if not id then -- dressingId or uniqueId
		id = categoryId
		return self.item.byDressingId[id] or self.item.byUniqueId[id]
	end

	local category = self.item.category[categoryId]
	return category and category[id]
end

Shop.getShamanItem = function(self, uniqueId)
	return self.item.shaman[uniqueId]
end

return Shop