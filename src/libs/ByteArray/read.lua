-- Optimization --
local bit_bor = bit.bor
local bit_bxor = bit.bxor
local bit_lshift = bit.lshift
local string_char = string.char
local table_arrayRange = table.arrayRange
local table_writeBytes = table.writeBytes
local type = type
------------------

local ByteArray = require("ByteArray/init")

--[[@
	@name read8
	@desc Extracts bytes from the packet stack. If there are not suficient bytes in the stack, it's filled with bytes of value 0.
	@param quantity<int> The quantity of bytes to be extracted. @default 1
	@returns table,int A table with the extracted bytes. If there's only one byte, it is sent instead of the table.
]]
ByteArray.read8 = function(self, quantity)
	quantity = quantity or 1

	local stackReadPos = self.stackReadPos + quantity
	local byteStack = table_arrayRange(self.stack, self.stackReadPos, stackReadPos - 1)
	self.stackReadPos = stackReadPos

	local sLen = #byteStack
	self.stackLen = self.stackLen - sLen

	local fillVal = quantity - sLen
	if fillVal > 0 then
		for i = 1, fillVal do
			byteStack[sLen + i] = 0
		end
	end

	return (quantity == 1 and byteStack[1] or byteStack)
end

--[[@
	@name read16
	@desc Extracts a short integer from the packet stack.
	@returns int A short integer.
]]
ByteArray.read16 = function(self)
	local shortStack = self:read8(2)
	-- s[1] << 8 + s[2]
	return bit_lshift(shortStack[1], 8) + shortStack[2]
end

--[[@
	@name readSigned16
	@desc Extracts a short signed integer from the packet stack.
	@returns int A short signed integer.
]]
ByteArray.readSigned16 = function(self)
	local shortStack = self:read8(2)
	-- ((s[1] << 8 | s[2] << 0) ~ 0x8000) - 0x8000
	return bit_bxor(bit_bor(bit_lshift(shortStack[1], 8), bit_lshift(shortStack[2], 0)), 0x8000)
		- 0x8000
end

--[[@
	@name read24
	@desc Extracts an integer from the packet stack.
	@returns int An integer.
]]
ByteArray.read24 = function(self)
	local intStack = self:read8(3)
	-- i[1] << 16 + i[2] << 8 + i[3]
	return bit_lshift(intStack[1], 16) + bit_lshift(intStack[2], 8) + intStack[3]
end

--[[@
	@name read32
	@desc Extracts a long integer from the packet stack.
	@returns int A long integer.
]]
ByteArray.read32 = function(self)
	local longStack = self:read8(4)
	-- l[1] << 24 + l[2] << 16 + l[3] << 8 + l[4]
	return bit_lshift(longStack[1], 24) + bit_lshift(longStack[2], 16) + bit_lshift(longStack[3], 8)
		+ longStack[4]
end

--[[@
	@name readUTF
	@desc Extracts a string from the packet stack.
	@returns string A string.
]]
ByteArray.readUTF = function(self)
	local byte = self:read8(self:read16())

	if type(byte) == "number" then
		return string_char(byte)
	end
	return table_writeBytes(byte)
end

--[[@
	@name readBigUTF
	@desc Extracts a long string from the packet stack.
	@returns string A long string.
]]
ByteArray.readBigUTF = function(self)
	local byte = self:read8(self:read24())

	if type(byte) == "number" then
		return string_char(byte)
	end
	return table_writeBytes(byte)
end

--[[@
	@name readBool
	@desc Extracts a boolean from the packet stack.
	@returns boolean Whether the byte is 1.
]]
ByteArray.readBool = function(self)
	return self:read8() == 1
end

----- Aliases -----
ByteArray.readByte  = "read8"
ByteArray.readShort = "read16"
ByteArray.readInt   = "read24"
ByteArray.readLong  = "read32"
-------------------