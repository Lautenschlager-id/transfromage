local byteArray = require("byteArray")
local bitwise = require("bitwise")

local cryptToSha256 
do
	local openssl = require("openssl")

	local sha256 = openssl.digest.get("sha256")
	cryptToSha256 = function(str)
		local hash = openssl.digest.new(sha256)
		hash:update(str)
		return hash:final()
	end
end

local getPasswordHash
do
	local base64 = require("base64")

	local saltBytes = {
		247, 026, 166, 222,
		143, 023, 118, 168,
		003, 157, 050, 184,
		161, 086, 178, 169,
		062, 221, 067, 157,
		197, 221, 206, 086,
		211, 183, 164, 005,
		074, 013, 008, 176
	}
	do
		local chars = { }
		for i = 1, #saltBytes do
			chars[i] = string.char(saltBytes[i])
		end

		saltBytes = table.concat(chars)
	end

	getPasswordHash = function(password)
		local hash = cryptToSha256(password)
		hash = cryptToSha256(hash .. saltBytes)
		local len = #hash

		local out, counter = { }, 0
		for i = 1, len, 2 do
			counter = counter + 1
			out[counter] = string.char(tonumber(string.sub(hash, i, (i + 1)), 16))
		end

		return base64.encode(table.concat(out))
	end
end

local packetKeys = { }
local identificationKeys = { }
local msgKeys = { }

local setPacketKeys = function(pkgKeys, idKeys, mesgKeys)
	packetKeys, identificationKeys, msgKeys = pkgKeys, idKeys, mesgKeys
end

local encodeChunks
do
	local DELTA, LIM = 0x9E3779B9, 0xFFFFFFFF
	local MX = function(z, y, sum, p, e)
		return bitwise.bxor(bitwise.bxor(bitwise.rshift(z, 5), bitwise.lshift(y, 2)) + bitwise.bxor(bitwise.rshift(y, 3), bitwise.lshift(z, 4)), bitwise.bxor(sum, y) + bitwise.bxor(identificationKeys[bitwise.bxor(bitwise.band(p, 3), e) + 1], z))
	end
	encodeChunks = function(v, n)
		local z, y, sum, p, e

		n = n or #v
		y = v[1]
		sum = 0
		if n > 1 then
			z = v[n]
			q = math.floor(tonumber(6 + 52 / n))
		end
		while q > 0 do
			q = q - 1
			sum = bitwise.band((sum + DELTA), LIM)
			e =  bitwise.band(bitwise.band(bitwise.rshift(sum, 2), LIM), 3)
			p = 0
			while p < (n - 1) do
				y = v[p + 2]
				z = bitwise.band((v[p+1] + MX(z, y, sum, p, e)), LIM)
				v[p + 1] = z
				p = p + 1
			end
			y = v[1]
			z = bitwise.band((v[n] + MX(z, y, sum, p, e)), LIM)
			v[n] = z
		end
		return v
	end
end

local blockCipher = function(packet)
	local stackLen = #packet.stack

	if stackLen == 0 then
		return error("Block cipher algorithm can't be applied to an empty ByteArray.")
	end

	while stackLen < 8 do
		stackLen = stackLen + 1
		packet.stack[stackLen] = 0
	end

	packet = byteArray:new(packet.stack)

	local chunks, counter = { }, 0
	while #packet.stack > 0 do
		counter = counter + 1
		chunks[counter] = packet:readLong()
	end

	chunks = encodeChunks(chunks)

	packet:writeShort(#chunks)
	for i = 1, #chunks do
		packet:writeLong(chunks[i])
	end

	return packet
end

local xorCipher = function(packet, fingerprint)
	local stack = { }

	for i = 1, #packet.stack do
		fingerprint = fingerprint + 1
		stack[i] = bit.band(bit.bxor(packet.stack[i], msgKeys[(fingerprint % 20) + 1]), 255)
	end

	return byteArray:new(stack)
end

return {
	getPasswordHash = getPasswordHash,
	setPacketKeys = setPacketKeys,
	blockCipher = blockCipher,
	xorCipher = xorCipher
}