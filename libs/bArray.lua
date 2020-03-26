-- Optimization --
local bit_band = bit.band
local bit_bor = bit.bor
local bit_bxor = bit.bxor
local bit_lshift = bit.lshift
local bit_rshift = bit.rshift
local string_char = string.char
local string_getBytes = string.getBytes
local table_add = table.add
local table_arrayRange = table.arrayRange
local table_mapArray = table.mapArray
local table_setNewClass = table.setNewClass
local table_writeBytes = table.writeBytes
------------------

local modulo256 = function(n)
	return n % 256
end

------------------

local byteArray = table.setNewClass()
byteArray.__tostring = function(this)
	return table_writeBytes(this.stack)
end

--[[@
	@name new
	@desc Creates a new instance of a Byte Array. Alias: `byteArray()`.
	@param stack?<table> An array of bytes.
	@returns byteArray The new Byte Array object.
	@struct {
		stack = { }, -- The bytes stack
		stackLen = 0 -- Total bytes stored in @stack
	}
]]
byteArray.new = function(self, stack)
	return setmetatable({
		stack = (stack or { }), -- Array of bytes
		stackLen = (stack and #stack or 0)
	}, self)
end
--[[@
	@name write8
	@desc Inserts bytes in the byte array.
	@param ...?<int> Bytes. @default 0
	@returns byteArray Object instance.
]]
byteArray.write8 = function(self, ...)
	local tbl = { ... }

	local tblLen = #tbl
	if tblLen == 0 then
		tblLen = 1

		tbl = { 0 }
	end
	self.stackLen = self.stackLen + tblLen

	local bytes = table_mapArray(tbl, modulo256)
	table_add(self.stack, bytes)
	return self
end
--[[@
	@name write16
	@desc Inserts a short integer in the byte array.
	@param short<int> An integer number in the range [0, 65535].
	@returns byteArray Object instance.
]]
byteArray.write16 = function(self, short)
	-- (long >> 8) & 0xFF, long & 0xFF
	return self:write8(
		bit_band(bit_rshift(short, 8), 0xFF),
		bit_band(short, 0xFF)
	)
end
--[[@
	@name write24
	@desc Inserts an integer in the byte array.
	@param int<int> An integer number in the range [0, 16777215].
	@returns byteArray Object instance.
]]
byteArray.write24 = function(self, int)
	-- (long >> 16) & 0xFF, (long >> 8) & 0xFF, long & 0xFF
	return self:write8(
		bit_band(bit_rshift(int, 16), 0xFF),
		bit_band(bit_rshift(int, 8), 0xFF),
		bit_band(int, 0xFF)
	)
end
--[[@
	@name write32
	@desc Inserts a long integer in the byte array.
	@param long<int> An integer number in the range [0, 4294967295].
	@returns byteArray Object instance.
]]
byteArray.write32 = function(self, long)
	-- (long >> 24) & 0xFF, (long >> 16) & 0xFF, (long >> 8) & 0xFF, long & 0xFF
	return self:write8(
		bit_band(bit_rshift(long, 24), 0xFF),
		bit_band(bit_rshift(long, 16), 0xFF),
		bit_band(bit_rshift(long, 8), 0xFF),
		bit_band(long, 0xFF)
	)
end
--[[@
	@name writeUTF
	@desc Inserts a string in the byte array.
	@param utf<table,string> A string/table with a maximum of 65535 characters/values.
	@returns byteArray Object instance.
]]
byteArray.writeUTF = function(self, utf)
	if type(utf) == "string" then
		utf = string_getBytes(utf)
	end

	local utfLen = #utf
	self:write16(utfLen)
	table_add(self.stack, utf)
	self.stackLen = self.stackLen + utfLen

	return self
end
--[[@
	@name writeBigUTF
	@desc Inserts a string in the byte array.
	@param utf<table,string> A string/table with a maximum of 16777215 characters/values.
	@returns byteArray Object instance.
]]
byteArray.writeBigUTF = function(self, bigUtf)
	if type(bigUtf) == "string" then
		bigUtf = string_getBytes(bigUtf)
	end

	local bigUtfLen = #bigUtf
	self:write24(bigUtfLen)
	table_add(self.stack, bigUtf)
	self.stackLen = self.stackLen + bigUtfLen

	return self
end
--[[@
	@name writeBool
	@desc Inserts a byte (0, 1) in the byte array.
	@param bool<boolean> A boolean.
]]
byteArray.writeBool = function(self, bool)
	self:write8(bool and 1 or 0)
	return self
end
--[[@
	@name read8
	@desc Extracts bytes from the packet stack. If there are not suficient bytes in the stack, it's filled with bytes with value 0.
	@param quantity<int> The quantity of bytes to be extracted. @default 1
	@returns table,int A table with the extracted bytes. If there's only one byte, it is sent instead of the table.
]]
byteArray.read8 = function(self, quantity)
	quantity = quantity or 1

	local byteStack = table_arrayRange(self.stack, 1, quantity)
	self.stack = table_arrayRange(self.stack, quantity + 1)

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
byteArray.read16 = function(self)
	local shortStack = self:read8(2)
	-- s[1] << 8 + s[2]
	return bit_lshift(shortStack[1], 8) + shortStack[2]
end
--[[@
	@name readSigned16
	@desc Extracts a short signed integer from the packet stack.
	@returns int A short signed integer.
]]
byteArray.readSigned16 = function(self)
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
byteArray.read24 = function(self)
	local intStack = self:read8(3)
	-- i[1] << 16 + i[2] << 8 + i[3]
	return bit_lshift(intStack[1], 16) + bit_lshift(intStack[2], 8) + intStack[3]
end
--[[@
	@name read32
	@desc Extracts a long integer from the packet stack.
	@returns int A long integer.
]]
byteArray.read32 = function(self)
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
byteArray.readUTF = function(self)
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
byteArray.readBigUTF = function(self)
	local byte = self:read8(self:read24())

	if type(byte) == "number" then
		return string_char(byte)
	end
	return table_writeBytes(byte)
end
--[[@
	@name readBool
	@desc Extracts a boolean from the packet stack. (Whether the next byte is 0 or 1)
	@returns boolean A boolean.
]]
byteArray.readBool = function(self)
	return self:read8() == 1
end

----- Compatibility -----
byteArray.readByte = "read8"
byteArray.readShort = "read16"
byteArray.readWrite = "read24"
byteArray.readLong = "read32"

byteArray.writeByte = "write8"
byteArray.writeShort = "write16"
byteArray.writeWrite = "write24"
byteArray.writeLong = "write32"
-------------------------

return byteArray