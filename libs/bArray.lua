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
	return table_writeBytes(this.buffer)
end

--[[@
	@name new
	@desc Creates a new instance of a Byte Array. Alias: `byteArray()`.
	@param buffer?<table> An array of bytes.
	@param pos?<int> A pointer to the current position in the buffer when reading.
	@returns byteArray The new Byte Array object.
	@struct {
		buffer = { } -- The bytes buffer
	}
]]
byteArray.new = function(self, buffer)
	return setmetatable({
		pos = 1,
		buffer = (buffer or { }) -- Array of bytes
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
	if #tbl == 0 then
		tbl = { 0 }
	end

	local bytes = table_mapArray(tbl, modulo256)
	table_add(self.buffer, bytes)
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

	self:write16(#utf)
	table_add(self.buffer, utf)

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

	self:write24(#bigUtf)
	table_add(self.buffer, bigUtf)

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
	@desc Extracts bytes from the packet buffer. If there are not suficient bytes in the buffer, it's filled with bytes with value 0.
	@param quantity<int> The quantity of bytes to be extracted. @default 1
	@returns table,int A table with the extracted bytes. If there's only one byte, it is sent instead of the table.
]]
byteArray.read8 = function(self, quantity)
	quantity = quantity or 1

	local byteBuffer = table_arrayRange(self.buffer, self.pos, self.pos + quantity)
	self.pos = self.pos + quantity

	local sLen = #byteBuffer
	local fillVal = quantity - sLen
	if fillVal > 0 then
		for i = 1, fillVal do
			byteBuffer[sLen + i] = 0
		end
	end

	return (quantity == 1 and byteBuffer[1] or byteBuffer)
end
--[[@
	@name read16
	@desc Extracts a short integer from the packet buffer.
	@returns int A short integer.
]]
byteArray.read16 = function(self)
	local shortBuffer = self:read8(2)
	-- s[1] << 8 + s[2]
	return bit_lshift(shortBuffer[1], 8) + shortBuffer[2]
end
--[[@
	@name readSigned16
	@desc Extracts a short signed integer from the packet buffer.
	@returns int A short signed integer.
]]
byteArray.readSigned16 = function(self)
	local shortBuffer = self:read8(2)
	-- ((s[1] << 8 | s[2] << 0) ~ 0x8000) - 0x8000
	return bit_bxor(bit_bor(bit_lshift(shortBuffer[1], 8), bit_lshift(shortBuffer[2], 0)), 0x8000)
		- 0x8000
end
--[[@
	@name read24
	@desc Extracts an integer from the packet buffer.
	@returns int An integer.
]]
byteArray.read24 = function(self)
	local intBuffer = self:read8(3)
	-- i[1] << 16 + i[2] << 8 + i[3]
	return bit_lshift(intBuffer[1], 16) + bit_lshift(intBuffer[2], 8) + intBuffer[3]
end
--[[@
	@name read32
	@desc Extracts a long integer from the packet buffer.
	@returns int A long integer.
]]
byteArray.read32 = function(self)
	local longBuffer = self:read8(4)
	-- l[1] << 24 + l[2] << 16 + l[3] << 8 + l[4]
	return bit_lshift(longBuffer[1], 24) + bit_lshift(longBuffer[2], 16) + bit_lshift(longBuffer[3], 8)
		+ longBuffer[4]
end
--[[@
	@name readUTF
	@desc Extracts a string from the packet buffer.
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
	@desc Extracts a long string from the packet buffer.
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
	@desc Extracts a boolean from the packet buffer. (Whether the next byte is 0 or 1)
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
