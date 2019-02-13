if not table.add then
	require("extensions")
end

local buffer = { }
buffer.__index = buffer

buffer.new = function(self)
	return setmetatable({
		queue = { }
	}, self)
end

buffer.isEmpty = function(self)
	return #self.queue == 0
end

buffer.receive = function(self, length)
	local bufferSize = #self.queue
	if bufferSize == 0 then
		return
	end

	if length >= bufferSize then
		local ret = self.queue
		self.queue = { }
		return ret
	end

	local ret = { }
	for b = 1, length do
		ret[b] = table.remove(self.queue, 1)
	end

	return ret
end

buffer.push = function(self, bytes)
	if type(bytes) == "string" then
		bytes = string.getBytes(bytes)
	end

	table.add(self.queue, bytes)

	return self
end

return buffer