local openssl = require("openssl")
local base64_encode = require("base64").encode

------------------------------------------- Optimization -------------------------------------------
local math_floor = math.floor
local string_char = string.char
local string_sub = string.sub
local table_concat = table.concat
local table_writeBytes = table.writeBytes
local tonumber = tonumber
----------------------------------------------------------------------------------------------------

local sha256 = openssl.digest.get("sha256")

local cryptToSha256 = function(str)
	local hash = openssl.digest.new(sha256)
	hash:update(str)
	return hash:final()
end

local saltBytes = table_writeBytes({
	0xF7, 0x1A, 0xA6, 0xDE,
	0x8F, 0x17, 0x76, 0xA8,
	0x03, 0x9D, 0x32, 0xB8,
	0xA1, 0x56, 0xB2, 0xA9,
	0x3E, 0xDD, 0x43, 0x9D,
	0xC5, 0xDD, 0xCE, 0x56,
	0xD3, 0xB7, 0xA4, 0x05,
	0x4A, 0x0D, 0x08, 0xB0
})

--[[@
	@name getPasswordHash
	@desc Encrypts the account's password.
	@param password<string> The account's password.
	@returns string The encrypted password.
]]
local getPasswordHash = function(password)
	local hash = cryptToSha256(password)
	hash = cryptToSha256(hash .. saltBytes)
	local len = #hash

	local out, counter = { }, 0
	for i = 1, len, 2 do
		counter = counter + 1
		out[counter] = string_char(tonumber(string_sub(hash, i, (i + 1)), 16))
	end

	return base64_encode(table_concat(out))
end

return getPasswordHash