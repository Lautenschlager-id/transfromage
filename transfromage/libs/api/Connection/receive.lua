local Connection = require("./init")

local ByteArray = require("classes/ByteArray")

------------------------------------------- Optimization -------------------------------------------
local bit_band   = bit.band
local bit_bor    = bit.bor
local bit_lshift = bit.lshift
----------------------------------------------------------------------------------------------------

--[[@
	@name receive
	@desc Retrieves the data received from the server.
	@returns table,nil The bytes that were removed from the buffer queue. Can be nil if the queue is empty or if a packet is only partially received.
]]
Connection.receive = function(self)
	local byte
	while self._isReadingStackLength and self.Buffer._count ~= 0 do
		byte = self.Buffer:receive(1)[1]
		-- r | (b&0x7F << l)
		self._readStackLength = bit_bor(self._readStackLength, bit_lshift(bit_band(byte, 0x7F),
			self._lengthBytes))
		-- Using multiples of 7 saves unnecessary multiplication in the formula above
		self._lengthBytes = self._lengthBytes + 7

		self._isReadingStackLength = (self._lengthBytes < 35 and bit_band(byte, 0x80) == 0x80)
	end

	if not self._isReadingStackLength and self.Buffer._count >= self._lengthBytes then
		local byteArr = self.Buffer:receive(self._readStackLength)

		self._isReadingStackLength = true
		self._readStackLength = 0
		self._lengthBytes = 0

		return ByteArray:new(byteArr)
	end
end