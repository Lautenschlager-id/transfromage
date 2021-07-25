------------------------------------------- Optimization -------------------------------------------
local getmetatable = getmetatable
local next         = next
local setmetatable = setmetatable
local string_char  = string.char
local table_concat = table.concat
local type         = type
----------------------------------------------------------------------------------------------------

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

	local newArray = { }
	if i > j then
		return newArray
	end

	local counter = 0
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
local table_copy
table_copy = function(list, checkMetatable)
	local out = { }
	for k, v in next, list do
		if type(v) == "table" then
			out[k] = table_copy(v)
		else
			out[k] = v
		end
	end

	if checkMetatable then
		local meta = getmetatable(list)
		if meta and type(meta) == "table" then
			out = setmetatable(out, meta)
		end
	end

	return out
end
table.copy = table_copy

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
	@param arr<table> The array to have its values modified.
	@param f<function> The function that handles the values of the array. It receives the values of the array as parameter.
	@returns table A new array with the modified values.
]]
table.mapArray = function(arr, f)
	local newArray = { }
	for i = 1, #arr do
		newArray[i] = f(arr[i])
	end
	return newArray
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