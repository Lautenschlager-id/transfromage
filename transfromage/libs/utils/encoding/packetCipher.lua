local ByteArray = require("classes/ByteArray")

------------------------------------------- Optimization -------------------------------------------
local bit_bxor = bit.bxor
----------------------------------------------------------------------------------------------------

--[[@
	@name xorCipher
	@desc Encodes a packet using the XOR cipher.
	@desc If @self.hasSpecialRole is true, then the raw packet is returned.
	@param packet<ByteArray> A Byte Array object to be encoded.
	@param fingerprint<int> The fingerprint of the encode.
	@returns ByteArray The encoded Byte Array object.
]]
local xorCipher = function(client, packet, fingerprint)
	if client.hasSpecialRole then
		return packet
	end

	local stack = { }

	local packetStack = packet.stack
	local messageKeys = client._messageKeys

	for i = 1, packet.stackLen do
		fingerprint = fingerprint + 1
		stack[i] = bit_bxor(packetStack[i], messageKeys[(fingerprint % 20) + 1]) % 256
	end

	return ByteArray:new(stack)
end

return xorCipher