------------------------------------------- Optimization -------------------------------------------
local outfitCategory = require("api/enum").outfitCategory
local setmetatable   = setmetatable
local string_format  = string.format
local string_gmatch  = string.gmatch
local string_gsub    = string.gsub
local string_match   = string.match
local string_upper   = string.upper
local tonumber       = tonumber
----------------------------------------------------------------------------------------------------

local Outfit = table.setNewClass("Outfit")

Outfit.new = function(self)
	return setmetatable({
		id = nil,

		look = nil,
		parsedLook = nil,

		flags = nil,
	}, self)
end

Outfit.parse = function(self)
	local look
	if self.__index == Outfit then
		look = self.look
	else
		look = self
		self = nil
	end

	local fur, items, color = string_match(look, "^(%d+);([^;]+);?(%x*)$")

	fur = tonumber(fur)
	if not fur then return end

	local outfit = {
		fur = fur,
		color = (color ~= '' and fur == 1) and color or nil
	}

	local itemCounter, tmpItem, tmpColorCounter, tmpColors = 0
	for item, colors in string_gmatch(items, "(%d+)([_+%x]*)") do
		tmpItem = {
			id = tonumber(item)
		}

		tmpColorCounter = 0
		if colors ~= '' then
			tmpColors = { }
			tmpItem.colors = tmpColors

			for color in string_gmatch(colors, "%x+") do
				tmpColorCounter = tmpColorCounter + 1
				tmpColors[tmpColorCounter] = color
			end
		end

		itemCounter = itemCounter + 1
		outfit[itemCounter] = tmpItem
	end

	if self then
		self.parsedLook = outfit
	end

	return outfit
end

Outfit.convertHexToInt = function(hex)
	return tonumber(hex, 16)
end

Outfit.convertIntToHex = function(int)
	return string_format("%06x", int)
end

Outfit.loadFromFashion = function(self, packet)
	self.id = packet:read16()

	self.look = packet:readUTF()
	self:parse()

	self.flags = packet:read8()

	return self
end

Outfit.load = function(self, packet, id)
	self.id = id

	self.look = packet:readUTF()
	self:parse()

	return self
end

Outfit.getFur = function(self)
	return self.parsedLook.fur, self.parsedLook.color
end

-- Generate all methods based on the enums
for category, id in pairs(outfitCategory) do
	Outfit["get" .. string_gsub(category, "%a", string_upper, 1)] = function(self)
		if not self.parsedLook then return end
		return self.parsedLook[id]
	end
end

return Outfit