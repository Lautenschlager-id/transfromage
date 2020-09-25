-- Optimization --
local string_byte = string.byte
local string_find = string.find
local string_gsub = string.gsub
local string_lower = string.lower
local string_sub = string.sub
local string_upper = string.upper
local tonumber = tonumber
local tostring = tostring
------------------

--[[@
	@name string.fixEntity
	@desc Normalizes a string that has HTML entities.
	@param str<string> The string.
	@returns string The normalized string.
]]
string.fixEntity = function(str)
	str = tostring(str)
	str = string_gsub(str, "&lt;", '<')
	str = string_gsub(str, "&amp;(#?)", '&%1')
	return str
end

--[[@
	@name string.getBytes
	@desc Gets the bytes of the characters of a string.
	@param str<string> The string.
	@returns table An array of bytes.
]]
string.getBytes = function(str)
	local len = #str
	if len > 8000 then -- avoids 'string slice too long'
		local out = { }
		for i = 1, len do
			out[i] = string_byte(str, i, i)
		end
		return out
	else
		return { string_byte(str, 1, -1) }
	end
end

--[[@
	@name string.split
	@desc Splits a string into parts based on a pattern.
	@param str<string> The string to be split.
	@param separator<string> The string that the function is going to use as separator.
	@param raw?<boolean> Whether @separator is a string or a pattern. @default false
	@returns table The data of the split string.
]]
string.split = function(str, separator, raw)
	local out, counter = { }, 0

	local strPos = 1
	local i, j
	while true do
		i, j = string_find(str, separator, strPos, raw)
		if not i then break end
		counter = counter + 1
		out[counter] = string_sub(str, strPos, i - 1)
		out[counter] = tonumber(out[counter]) or out[counter]

		strPos = j + 1
	end
	counter = counter + 1
	out[counter] = string_sub(str, strPos)
	out[counter] = tonumber(out[counter]) or out[counter]

	return out, counter
end

--[[@
	@name string.toNickname
	@desc Normalizes an inserted nickname.
	@param str<string> The nickname to be normalized. May not included the #tag.
	@param checkDiscriminator?<boolean> If it must append '#0000' if no #tag is detected. @default false
	@returns string The normalized nickname.
]]
string.toNickname = function(str, checkDiscriminator)
	str = tostring(str)
	str = string_lower(str)
	str = string_gsub(str, "%a", string_upper, 1)

	if checkDiscriminator and not string_find(str, '#', -5, true) then
		str = str .. "#0000"
	end

	return str
end