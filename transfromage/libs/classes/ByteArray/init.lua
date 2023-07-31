------------------------------------------- Optimization -------------------------------------------
local table_copy       = table.copy
local table_writeBytes = table.writeBytes
local type             = type
local setmetatable     = setmetatable
local string_getBytes  = string.getBytes
----------------------------------------------------------------------------------------------------

local ByteArray = table.setNewClass("ByteArray")

--[[@
	@name ByteArray.__tostring
	@desc Generates a string with the bytes of the array.
	@returns string A string with the bytes of the array. Doesn't consider the stack position.
]]
ByteArray.__tostring = function(this)
	return table_writeBytes(table_copy(this.stack))
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
	@#IF DEBUG
	if type(stack) == "string" then
		stack = string_getBytes(stack)
	end
	@#ENDIF

	return setmetatable({
		stack = (stack or { }), -- Array of bytes
		stackLen = (stack and #stack or 0),
		_stackReadPos = 1
	}, self)
end

--[[@
	@name duplicate
	@desc Clones the ByteArray into a new object.
	@returns ByteArray The new, cloned Byte Array object.
]]
ByteArray.duplicate = function(self)
	return ByteArray:new(table_copy(self.stack))
end

return ByteArray