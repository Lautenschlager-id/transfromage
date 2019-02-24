string.getBytes = function(s)
	local len = #s
	if len > 8000 then -- avoids 'string slice too long'
		local out = { }
		for i = 1, len do
			out[i] = string.byte(s, i, i)
		end
		return out
	else
		return { string.byte(s, 1, -1) }
	end
end

string.fixEntity = function(s)
	s = tostring(s)
	s = string.gsub(s, "&lt;", '<')
	s = string.gsub(s, "&amp;(#?)", '&%1')
	return s
end

string.toNickname = function(s, checkDiscriminator)
	s = tostring(s)
	s = string.lower(s)
	s = string.gsub(s, "%a", string.upper, 1)

	if checkDiscriminator and not string.find(s, '#') then
		s = s .. "#0000"
	end

	return s
end

table.writeBytes = function(b)
	return table.concat(table.mapArray(b, string.char))
end

table.add = function(src, add)
	local len = #src
	for i = 1, #add do
		src[len + i] = add[i]
	end
end

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

table.arrayRange = function(array, i, j)
	i = i or 1
	j = j or #array
	if i > j then return { } end

	local newArray, counter = { }, 0
	for v = i, j do
		counter = counter + 1
		newArray[counter] = array[v]
	end
	return newArray
end

table.mapArray = function(array, f)
	local newArray = { }
	for i = 1, #array do
		newArray[i] = f(array[i])
	end
	return newArray
end

table.join = function(list, value)
	local out = { }
	local tlen, len = #t, 0
	for i = 1, tlen do
		len = len + 1
		out[len] = t[i]
		if i < tlen then
			len = len + 1
			out[len] = value
		end
	end
	return out
end