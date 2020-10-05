------------------------------------------- Optimization -------------------------------------------
local setmetatable    = setmetatable
local string_getBytes = string.getBytes
local table_add       = table.add
local table_remove    = table.remove
local type            = type
----------------------------------------------------------------------------------------------------

local Buffer = table.setNewClass()

--[[@
	@name new
	@desc Creates a new instance of Buffer. Alias: `Buffer()`.
	@returns Buffer The new Buffer object.
	@struct {
		queue = { }, -- The bytes queue
		_count = 0 -- The number of bytes in the queue
	}
]]
Buffer.new = function(self)
	return setmetatable({
		queue = { },
		_count = 0
	}, self)
end

--[[@
	@name receive
	@desc Retrieves bytes from the queue.
	@param length<int> The quantity of bytes to be extracted.
	@returns table An array of bytes.
]]
Buffer.receive = function(self, length)
	if self._count == 0 then return end

	if length >= self._count then
		local ret = self.queue
		self.queue = { }
		self._count = 0
		return ret
	end

	local ret = { }
	for b = 1, length do
		ret[b] = table_remove(self.queue, 1)
	end
	self._count = self._count - length

	return ret
end

--[[@
	@name push
	@desc Inserts bytes to the queue.
	@param bytes<table,string> A string/table of bytes.
	@returns Buffer Object instance.
]]
Buffer.push = function(self, bytes)
	if type(bytes) == "string" then
		bytes = string_getBytes(bytes)
	end

	table_add(self.queue, bytes)
	self._count = self._count + #bytes

	return self
end

return Buffer