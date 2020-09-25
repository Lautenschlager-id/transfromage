local ByteArray = require("ByteArray")

-- Optimization --
local bit_bxor = bit.bxor
------------------

--[[@
	@name xorCipher
	@desc Encodes a packet using the XOR cipher.
	@desc If @self.hasSpecialRole is true, then the raw packet is returned.
	@param packet<ByteArray> A Byte Array object to be encoded.
	@param fingerprint<int> The fingerprint of the encode.
	@returns ByteArray The encoded Byte Array object.
]]
local xorCipher = function(self, packet, fingerprint)
	if self.hasSpecialRole then
		return packet
	end

	local stack = { }

	for i = 1, packet.stackLen do
		fingerprint = fingerprint + 1
		stack[i] = bit_bxor(packet.stack[i], self.messageKeys[(fingerprint % 20) + 1]) % 256
	end

	return ByteArray:new(stack)
end

return xorCipher