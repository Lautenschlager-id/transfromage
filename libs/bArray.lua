if not string.getBytes then
	require("extensions")
end

local byteArray = { }

byteArray.__index = byteArray

byteArray.new = function(self, stack)
	return setmetatable({
		stack = (stack or { }) -- Array of bytes
	}, self)
end

byteArray.write8 = function(self, ...)
	local tbl = { ... }
	if #tbl == 0 then
		tbl = { 0 }
	end

	local bytes = table.mapArray(tbl, function(n) return n % 256 end)
	table.add(self.stack, bytes)
	return self
end

byteArray.write16 = function(self, short)
	return self:write8(bit.band(bit.rshift(short, 8), 255), bit.band(short, 255))
end

byteArray.write24 = function(self, integer)
	return self:write8(bit.band(bit.rshift(integer, 16), 255), bit.band(bit.rshift(integer, 8), 255), bit.band(integer, 255))
end

byteArray.write32 = function(self, long)
	return self:write8(bit.band(bit.rshift(long, 24), 255), bit.band(bit.rshift(long, 16), 255), bit.band(bit.rshift(long, 8), 255), bit.band(long, 255))
end

byteArray.writeUTF = function(self, utf)
	self:write16(#utf)

	if type(utf) == "string" then
		utf = string.getBytes(utf)
	end
	table.add(self.stack, utf)

	return self
end

byteArray.writeBigUTF = function(self, bigUtf)
	self:write24(#bigUtf)
	table.add(self.stack, string.getBytes(bigUtf))
	return self
end

byteArray.writeBool = function(self, boolean)
	self:write8(boolean and 1 or 0)
	return self
end

byteArray.read8 = function(self, bytesQuantity)
	bytesQuantity = bytesQuantity or 1

	local byteStack = table.arrayRange(self.stack, 1, bytesQuantity)
	self.stack = table.arrayRange(self.stack, bytesQuantity + 1)

	local sLen = #byteStack
	local fillVal = bytesQuantity - sLen
	if fillVal > 0 then
		for i = 1, fillVal do
			byteStack[sLen + i] = 0
		end
	end

	return (#byteStack ~= 1) and byteStack or byteStack[1]
end

byteArray.read16 = function(self)
	local shortStack = self:read8(2)
	return bit.lshift(shortStack[1], 8) + shortStack[2]
end

byteArray.read24 = function(self)
	local intStack = self:read8(3)
	return bit.lshift(intStack[1], 16) + bit.lshift(intStack[2], 8) + intStack[3]
end

byteArray.read32 = function(self)
	local longStack = self:read8(4)
	return bit.lshift(longStack[1], 24) + bit.lshift(longStack[2], 16) + bit.lshift(longStack[3], 8) + longStack[4]
end

byteArray.readUTF = function(self)
	local byte = self:read8(self:read16())

	if type(byte) == "number" then
		return string.char(byte)
	end
	return table.writeBytes(byte)
end

byteArray.readBigUTF = function(self)
	local byte = self:read8(self:read24())

	if type(byte) == "number" then
		return string.char(byte)
	end
	return table.writeBytes(byte)
end

byteArray.readBool = function(self)
	return self:read8() == 1
end

----- Compatibility -----
byteArray.readByte, byteArray.readShort, byteArray.readWrite, byteArray.readLong = byteArray.read8, byteArray.read16, byteArray.read24, byteArray.read32
byteArray.writeByte, byteArray.writeShort, byteArray.writeWrite, byteArray.writeLong = byteArray.write8, byteArray.write16, byteArray.write24, byteArray.write32

return byteArray
