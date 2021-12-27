local ShopItem = require("./ShopItem")
local ShopShamanItem = require("./ShopShamanItem")

local Outfit = require("./Outfit")

------------------------------------------- Optimization -------------------------------------------
local setmetatable = setmetatable
local string_sub   = string.sub
local table_copy   = table.copy
----------------------------------------------------------------------------------------------------

local Shop = table.setNewClass("Shop")

Shop.new = function(self)
	return setmetatable({
		totalCheese = nil,
		totalFraise = nil,

		currentOutfit = nil,
		ownedItems = { },

		purchasableItems = { },
		purchasableShamanItems = { },

		fashionSquadOutfits = { },
		ownedOutfits = { },

		ownedShamanItems = { }
	}, self)
end

Shop.load = function(self, packet)
	self.totalCheese = packet:read32()
	self.totalFraise = packet:read32()

	self.currentOutfit = Outfit:new():load(packet, -1)

	-- Owned items
	for i = 1, packet:read32() do
		self.ownedItems[i] = ShopItem:new():loadOwned(packet)
	end

	-- Available items in the shop that haven't been purchased yet
	for i = 1, packet:read32() do
		self.purchasableItems[i] = ShopItem:new():loadPurchasable(packet)
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
		self.ownedShamanItems[i] = ShopShamanItem:new():loadOwned(packet)
	end

	-- Available shaman items in the shop that haven't been purchased yet
	for i = 1, packet:read16() do
		self.purchasableShamanItems[i] = ShopShamanItem:new():loadPurchasable(packet)
	end

	p(packet:read8(100))
end

return Shop