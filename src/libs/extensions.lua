-- Optimization --
local bit_rshift = bit.rshift
local coroutine_wrap = coroutine.wrap
local math_ceil = math.ceil
local math_floor = math.floor
local string_byte = string.byte
local string_char = string.char
local string_find = string.find
local string_format = string.format
local string_gmatch = string.gmatch
local string_gsub = string.gsub
local string_lower = string.lower
local string_sub = string.sub
local string_upper = string.upper
local table_concat = table.concat
------------------

--[[@
	@name coroutine.makef
	@desc Creates a coroutine to execute the given function.
	@param f<function> Function to be executed inside a coroutine.
	@returns function A coroutine with @f to be executed.
]]
coroutine.makef = function(f)
	return function(...)
		return coroutine_wrap(f)(...)
	end
end
do
	local pixelFrame = 8 / 27
	--[[@
		@name math.normalizePoint
		@desc Normalizes a Transformice coordinate point value.
		@param n<number> The coordinate point value.
		@returns int The normalized coordinate point value.
	]]
	math.normalizePoint = function(n)
		n = n * pixelFrame
		return (n > 0 and math_floor(n) or n < 0 and math_ceil(n) or n)
	end
end
do
	local color = "\27[%sm%s\27[0m"
	local theme = { -- Scrapped from utils.theme
		error = "1;31",
		failure = "1;33;41",
		highlight = "1;36;44",
		info = "1;36",
		success = "0;32"
	}

	local formatColor = function(format, code, text)
		return (theme[code] and string_format(color, theme[code], text) or format)
	end

	--[[@
		@name os.log
		@desc Sends a log message with colors to the prompt of command.
		@desc Color format is given as `↑name↓text↑`, as in `↑error↓[FAIL]↑`.
		@desc Available code names: `error`, `failure`, `highlight`, `info`, `success`.
		@desc This function is also available for the `error` function. Ex: `error("↑error↓Bug↑")`
		@param str<string> The message to be sent. It may included color formats.
		@param returnValue?<boolean> Whether the formated message has to be returned. If not, it'll be sent to the prompt automatically. @default false
		@returns nil,string The formated message, depending on @returnValue.
	]]
	os.log = function(str, returnValue)
		str = string_gsub(tostring(str), "(↑(.-)↓(.-)↑)", formatColor)

		if returnValue then
			return str
		end
		print(str)
	end

	local err = error
	_G.error = function(message, level) -- _G avoids bugs
		os.log(message) -- Clean message
		return err('^', level)
	end
end
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
do
	-- Based on Luvit's ustring

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
end
--[[@
	@name table.add
	@desc Links two arrays by reference.
	@param str<table> The source table, the one receiving the new values.
	@param add<table> The table where the new values are coming from.
]]
table.add = function(src, add)
	local len = #src
	for i = 1, #add do
		src[len + i] = add[i]
	end
end
--[[@
	@name table.arrayRange
	@desc Gets the values of an array within a given range.
	@param arr<table> The array.
	@param i?<int> The initial index of the range. @default 1
	@param j?<int> The final index of the range. @default #@arr
	@returns table A new array with the values obtained from @arr within the range [@i, @j].
]]
table.arrayRange = function(arr, i, j)
	i = i or 1
	j = j or #arr
	if i > j then return { } end

	local newArray, counter = { }, 0
	for v = i, j do
		counter = counter + 1
		newArray[counter] = arr[v]
	end
	return newArray
end
--[[@
	@name table.copy
	@desc Copies a table to remove its reference.
	@param list<table> The table to be copied.
	@returns table A new table with all values and indexes of @list.
]]
table.copy = function(list)
	local out = { }
	for k, v in next, list do
		if type(v) == "table" then
			out[k] = table.copy(v)
		else
			out[k] = v
		end
	end
	return out
end
--[[@
	@name table.fuse
	@desc Links two given arrays.
	@param arrA<table> The source table, the one receiving the new values.
	@param arrB<table> The table where the new values are coming from.
	@returns table The new table with the values of both @arrA and @arrB.
]]
table.fuse = function(arrA, arrB)
	local out, len = { }, #arrA
	for i = 1, len do
		out[i] = arrA[i]
	end
	for i = 1, #arrB do
		out[len + i] = arrB[i]
	end
	return out
end
--[[@
	@name table.join
	@desc Splits an array, adding a value between each value.
	@param arr<table> The array to be split.
	@param value<*> The value to be added between the values of @arr.
	@returns table The split array.
]]
table.join = function(arr, value)
	local out = { }
	local tlen, len = #arr, 0
	for i = 1, tlen do
		len = len + 1
		out[len] = arr[i]
		if i < tlen then
			len = len + 1
			out[len] = value
		end
	end
	return out
end
--[[@
	@name table.mapArray
	@desc Transforms the values in a given array.
	@param arr<table> The array to have its values altered.
	@param f<function> The function that handles the values of the array. It receives the values of the array as parameter.
	@returns table A new array with the altered values.
]]
table.mapArray = function(arr, f)
	local newArray = { }
	for i = 1, #arr do
		newArray[i] = f(arr[i])
	end
	return newArray
end
--[[@
	@name table.setNewClass
	@desc Creates a new class constructor.
	@desc If the table receives a new index with a string value, it'll create an alias.
	@returns table A metatable with constructor and alias handlers.
]]
table.setNewClass = function()
	local class = setmetatable({ }, {
		__call = function(this, ...)
			return this:new(...)
		end,
		__newindex = function(this, index, value)
			if type(value) == "string" then -- Aliases / Compatibility
				rawset(this, index, function(self, ...)
					os.log("↑failure↓[/!\\]↑ ↑highlight↓" .. index .. "↑ is deprecated, use ↑highl\z
						ight↓" .. value .. "↑ instead.")
					return this[value](self, ...)
				end)
			else
				rawset(this, index, value)
			end
		end
	})
	class.__index = class

	return class
end
--[[@
	@name table.writeBytes
	@desc Converts an array of bytes into a string. (Not a bytestring)
	@param bytes<table> The array of bytes.
	@returns string A string from the array of bytes.
]]
table.writeBytes = function(bytes)
	for i = 1, #bytes do
		bytes[i] = string_char(bytes[i])
	end
	return table_concat(bytes)
end