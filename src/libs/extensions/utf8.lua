-- Based on Luvit's ustring

-- Optimization --
local bit_rshift = bit.rshift
local string_byte = string.byte
local string_sub = string.sub
------------------

--[[@
	@name charLength
	@desc Gets the quantity of bytes in a character.
	@param byte<int> A byte to be used as source.
	@returns int The quantity of bytes in a character - 1.
]]
local charLength = function(byte)
	if bit_rshift(byte, 7) == 0x00 then
		return 1
	elseif bit_rshift(byte, 5) == 0x06 then
		return 2
	elseif bit_rshift(byte, 4) == 0x0E then
		return 3
	elseif bit_rshift(byte, 3) == 0x1E then
		return 4
	end
	return 0
end

--[[@
	@name string.utf8
	@desc Transforms a Lua string into a UTF8 string.
	@param str<string> The string.
	@returns table A table split by UTF8 char.
]]
string.utf8 = function(str)
	local utf8str = { }
	local index, append = 1, 0

	local charLen

	for i = 1, #str do
		repeat
			local char = string_sub(str, i, i)
			local byte = string_byte(char)
			if append ~= 0 then
				utf8str[index] = utf8str[index] .. char
				append = append - 1

				if append == 0 then
					index = index + 1
				end
				break
			end

			charLen = charLength(byte)
			utf8str[index] = char
			if charLen == 1 then
				index = index + 1
			end
			append = append + charLen - 1
		until true
	end

	return utf8str
end