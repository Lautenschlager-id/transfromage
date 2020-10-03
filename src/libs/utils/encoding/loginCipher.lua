local ByteArray = require("ByteArray")
local bit64 = require("bit64")

-- Optimization --
local bit64_band = bit64.band
local bit64_bxor = bit64.bxor
local bit64_lshift = bit64.lshift
local bit64_rshift = bit64.rshift
local math_floor = math.floor
------------------

local DELTA, LIM = 0x9E3779B9, 0xFFFFFFFF

-- Aux function for XXTEA
local MX = function(identificationKeys, z, y, sum, p, e)
	-- (((z >> 5) ^ (y << 2)) + ((y >> 3) ^ (z << 4))) ^ ((sum ^ y) + (keys[((p & 3) ^ e) + 1] ^ z))
	return bit64_bxor(
		bit64_bxor(bit64_rshift(z, 5), bit64_lshift(y, 2))
		+ bit64_bxor(bit64_rshift(y, 3), bit64_lshift(z, 4))
		, bit64_bxor(sum, y)
		+ bit64_bxor(identificationKeys[bit64_bxor(bit64_band(p, 3), e) + 1], z)
	)
end

--[[@
	@name xxtea
	@desc XXTEA partial 64bits encoder.
	@param self<encode> An Encode object.
	@param data<table> A table with data to be encoded.
	@returns table The encoded data.
]]
local xxtea = function(data, identificationKeys)
	local decode = #data

	local y = data[1]
	local z = data[decode]

	local sum = 0

	local e, p
	local q = math_floor(6 + 52 / decode)
	while q > 0 do
		q = q - 1

		sum = bit64_band((sum + DELTA), LIM)
		e = bit64_band(bit64_band(bit64_rshift(sum, 2), LIM), 3)

		p = 0
		while p < (decode - 1) do
			y = data[p + 2]

			z = bit64_band((data[p + 1] + MX(identificationKeys, z, y, sum, p, e)), LIM)
			data[p + 1] = z

			p = p + 1
		end

		y = data[1]

		z = bit64_band((data[decode] + MX(identificationKeys, z, y, sum, p, e)), LIM)
		data[decode] = z
	end

	return data
end

--[[@
	@name btea
	@desc Encodes a packet with the BTEA block cipher.
	@param packet<ByteArray> A Byte Array object to be encoded.
	@returns ByteArray The encoded Byte Array object.
]]
local btea = function(packet, identificationKeys)
	local stackLen = packet.stackLen

	while stackLen < 8 do
		stackLen = stackLen + 1
		packet.stack[stackLen] = 0 -- write8 would be slower
	end
	packet.stackLen = stackLen

	local chunks, counter = { }, 0
	while packet.stackLen > 0 do
		counter = counter + 1
		chunks[counter] = packet:read32()
	end

	chunks = xxtea(chunks, identificationKeys)

	packet = ByteArray:new():write16(counter)
	for i = 1, counter do
		packet:write32(chunks[i])
	end

	return packet
end

return btea