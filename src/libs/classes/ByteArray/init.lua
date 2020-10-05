------------------------------------------- Optimization -------------------------------------------
local table_writeBytes = table.writeBytes
local setmetatable = setmetatable
----------------------------------------------------------------------------------------------------

local ByteArray = table.setNewClass()

ByteArray.__tostring = function(this)
	return table_writeBytes(this.stack)
end

--[[@
	@name new
	@desc Creates a new instance of a Byte Array. Alias: `ByteArray()`.
	@desc Note that you must not write bytes after reading the packet. Use a new instance instead.
	@param stack?<table> An array of bytes.
	@returns ByteArray The new Byte Array object.
	@struct {
		stack = { }, -- The bytes stack
		stackLen = 0 -- Total bytes stored in @stack
	}
]]
ByteArray.new = function(self, stack)
	return setmetatable({
		stack = (stack or { }), -- Array of bytes
		stackLen = (stack and #stack or 0),
		stackReadPos = 1,
		stackReadLen = 0
	}, self)
end

return ByteArray