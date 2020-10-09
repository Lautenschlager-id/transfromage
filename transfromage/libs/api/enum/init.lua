------------------------------------------- Optimization -------------------------------------------
local error = error
local next = next
local setmetatable = setmetatable
local tostring = tostring
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
				return error("↑failure↓[ENUM]↑ Enumeration conflict in ↑highlight↓" .. tostring(k)
					.. "↑ and ↑highlight↓" .. tostring(reversed[v]) .. "↑", -2)
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
				return error("↑failure↓[ENUM]↑ Can not overwrite enumerations.", -2)
			end,
			__metatable = "enumeration"
		})
	end
})

return enum