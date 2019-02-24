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

byteArray.writeByte = function(self, ...)
	local tbl = { ... }
	if #tbl == 0 then
		tbl = { 0 }
	end

	local bytes = table.mapArray(tbl, function(n) return n % 256 end)
	table.add(self.stack, bytes)
	return self
end

byteArray.writeShort = function(self, short)
	return self:writeByte(bit.band(bit.rshift(short, 8), 255), bit.band(short, 255))
end

byteArray.writeInt = function(self, integer)
	return self:writeByte(bit.band(bit.rshift(integer, 16), 255), bit.band(bit.rshift(integer, 8), 255), bit.band(integer, 255))
end

byteArray.writeLong = function(self, long)
	return self:writeByte(bit.band(bit.rshift(long, 24), 255), bit.band(bit.rshift(long, 16), 255), bit.band(bit.rshift(long, 8), 255), bit.band(long, 255))
end

byteArray.writeUTF = function(self, utf)
	self:writeShort(#utf)

	if type(utf) == "string" then
		utf = string.getBytes(utf)
	end
	table.add(self.stack, utf)

	return self
end

byteArray.writeBigUTF = function(self, bigUtf)
	self:writeInt(#bigUtf)
	table.add(self.stack, string.getBytes(bigUtf))
	return self
end

byteArray.writeBool = function(self, boolean)
	self:writeByte(boolean and 1 or 0)
	return self
end

byteArray.readByte = function(self, bytesQuantity)
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

byteArray.readShort = function(self)
	local shortStack = self:readByte(2)
	return bit.lshift(shortStack[1], 8) + shortStack[2]
end

byteArray.readInt = function(self)
	local intStack = self:readByte(3)
	return bit.lshift(intStack[1], 16) + bit.lshift(intStack[2], 8) + intStack[3]
end

byteArray.readLong = function(self)
	local longStack = self:readByte(4)
	return bit.lshift(longStack[1], 24) + bit.lshift(longStack[2], 16) + bit.lshift(longStack[3], 8) + longStack[4]
end

byteArray.readUTF = function(self)
	local byte = self:readByte(self:readShort())

	if type(byte) == "number" then
		return string.char(byte)
	end
	return table.writeBytes(byte)
end

byteArray.readBigUTF = function(self)
	local byte = self:readByte(self:readInt())

	if type(byte) == "number" then
		return string.char(byte)
	end
	return table.writeBytes(byte)
end

byteArray.readBool = function(self)
	return self:readByte() == 1
end

return byteArray
