local enum_errors = require("./enums/error")

------------------------------------------- Optimization -------------------------------------------
local error           = error
local next            = next
local setmetatable    = setmetatable
local tostring        = tostring
local enum_error      = enum_errors.error
local enum_errorLevel = enum_errors.errorLevel

----------------------------------------------------------------------------------------------------

local enum = setmetatable({ }, {
	--[[@
		@name enum
		@desc Creates a new enumeration.
		@param list<table> The table that will become an enumeration.
		@param ignoreConflict?<boolean> If the system should ignore value conflicts. (if there are identical values in @list) @default false
		@param __index?<function> A function to handle the __index metamethod of the enumeration. It receives the given index and @list.
		@returns enum A new enumeration.
	]]
	__call = function(_, list, ignoreConflit, __index)
		local reversed = { }

		for k, v in next, list do
			if not ignoreConflit and reversed[v] then
				return error(enum_error.enumConflict, enum_errorLevel.low, tostring(k),
					tostring(reversed[v]))
			end
			reversed[v] = k
		end

		return setmetatable({ }, {
			__index = function(_, index)
				if __index then
					index = __index(index, list)
				end
				return list[index]
			end,
			__call = function(_, value)
				return reversed[value]
			end,
			__pairs = function()
				return next, list
			end,
			__len = function()
				return #list
			end,
			__newindex = function()
				return error(enum_error.enumOverwrite, enum_errorLevel.low)
			end,
			__metatable = "enumeration"
		})
	end
})

enum.error = enum(enum_error)
enum.errorLevel = enum(enum_errorLevel)

return enum