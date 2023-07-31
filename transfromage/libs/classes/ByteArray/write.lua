local ByteArray = require("./init")

------------------------------------------- Optimization -------------------------------------------
local bit_rshift      = bit.rshift
local string_getBytes = string.getBytes
local table_add       = table.add
local type            = type
----------------------------------------------------------------------------------------------------

--[[@
	@name write8
	@desc Inserts bytes in the byte array.
	@param ...?<int> Bytes. @default 0
	@returns ByteArray Object instance.
]]
ByteArray.write8 = function(self, ...)
	local bytes = { ... }

	local bytesLen = #bytes
	if bytesLen == 0 then
		bytesLen = 1

		bytes = { 0 }
	end
	self.stackLen = self.stackLen + bytesLen

	for i = 1, #bytes do
		-- It could be n & 0xFF but, in Lua, modulo is slightly more performatic
		bytes[i] = bytes[i] % (0xFF + 1)
	end
	table_add(self.stack, bytes)

	return self
end

--[[@
	@name write16
	@desc Inserts a short integer in the byte array.
	@param short<int> An integer number in the range [0, 65535|0xFFFF].
	@returns ByteArray Object instance.
]]
ByteArray.write16 = function(self, short)
	-- (short >> 8), long
	return self:write8(bit_rshift(short, 8), short)
end

--[[@
	@name write24
	@desc Inserts an integer in the byte array.
	@param int<int> An integer number in the range [0, 16777215|0xFFFFFF].
	@returns ByteArray Object instance.
]]
ByteArray.write24 = function(self, int)
	-- (int >> 16), (int >> 8), int
	return self:write8(bit_rshift(int, 16), bit_rshift(int, 8), int)
end

--[[@
	@name write32
	@desc Inserts a long integer in the byte array.
	@param long<int> An integer number in the range [0, 2147483647|0x7FFFFFFF].
	@returns ByteArray Object instance.
]]
ByteArray.write32 = function(self, long)
	-- (long >> 24), (long >> 16), (long >> 8), long
	return self:write8(bit_rshift(long, 24), bit_rshift(long, 16), bit_rshift(long, 8), long)
end

--[[@
	@name writeUTF
	@desc Inserts a string in the byte array.
	@param utf<table,string> A string/table with a maximum of 65535 [0xFFFF] characters/values.
	@returns ByteArray Object instance.
]]
ByteArray.writeUTF = function(self, utf)
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
	@desc Inserts a big string in the byte array.
	@param utf<table,string> A string/table with a maximum of 16777215 [0xFFFFFF] characters/values.
	@returns ByteArray Object instance.
]]
ByteArray.writeBigUTF = function(self, bigUtf)
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
ByteArray.writeBool = function(self, bool)
	return self:write8(bool and 1 or 0)
end

--------------------------------------- Deprecated / Aliases ---------------------------------------
ByteArray.writeByte  = "write8"
ByteArray.writeShort = "write16"
ByteArray.writeInt   = "write24"
ByteArray.writeLong  = "write32"
----------------------------------------------------------------------------------------------------