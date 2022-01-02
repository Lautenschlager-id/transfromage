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

			},
			-- [uid]
		},

		ownedItems = { },
		purchasableItems = { },
		purchasableShamanItems = { },

		ownedShamanItems = { },

		fashionSquadOutfits = { },
		ownedOutfits = { }
	}, self)
end

local insertItem = function(self, item)
	local itemList = self.item

	if not itemList.category[item.category] then
		itemList.category[item.category] = { }
	end
	itemList.category[item.category][item.id] = item

	local category = item.category
	if item.id > 99 then
		category = (category == 0 and "10") or (category == 22 and "230") or (category == 5 and "60") or category
	end
	itemList[(category .. item.id) * 1] = item
end

local checkItemSale = function(self, item)
	local category = item.category
	if category and item.id > 99 then
		category = (category == 0 and "10") or (category == 22 and "230") or (category == 5 and "60") or category
	end
	local sale = self.sales[category and ((category .. item.id) * 1) or item.uid]

	if not sale then return end

	if not sale.isShamanItem and not item.id then return end

	item.isOnSale = true

	if not item.fraisePrice then return end
	item.fraisePriceWithDiscount = math_ceil(item.fraisePrice -
		(item.fraisePrice * (sale.discountPercentage / 100)))
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
	end

	-- Available items in the shop that haven't been purchased yet
	for i = 1, packet:read32() do
		tmpItem = ShopItem:new():loadPurchasable(packet)
		self.purchasableItems[i] = tmpItem
		insertItem(self, tmpItem)
		checkItemSale(self, tmpItem)
	end

	-- Currently available FS outfits
	for i = 1, packet:read8() do
		self.fashionSquadOutfits[i] = Outfit:new():loadFromFashion(packet)
	end

	-- Outfits the account currently owns
	for i = 1, packet:read16() do
		self.ownedOutfits[i] = Outfit:new():load(packet, i)
	end

	-- Owned shaman items
	for i = 1, packet:read16() do
		tmpItem = ShopShamanItem:new():loadOwned(packet)

		self.ownedShamanItems[i] = tmpItem
		self.item.shaman[tmpItem.uid] = tmpItem
		checkItemSale(self, tmpItem)
	end

	-- Available shaman items in the shop that haven't been purchased yet
	for i = 1, packet:read16() do
		tmpItem = ShopShamanItem:new():loadPurchasable(packet)

		self.purchasableShamanItems[i] = tmpItem
		self.item.shaman[tmpItem.uid] = tmpItem
		checkItemSale(self, tmpItem)
	end
end

Shop.getItem = function(self, category, id)
	if category and not id then -- uid provided
		return self.item[category]
	else
		category = self.item.category[category]
		return category and category[id]
	end
end

Shop.getShamanItem = function(self, uid)
	return self.item.shaman[uid]
end

return Shop