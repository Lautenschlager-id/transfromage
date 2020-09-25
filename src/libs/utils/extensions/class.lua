-- Optimization --
local rawset = rawset
local setmetatable = setmetatable
local type = type
------------------

local classMeta = { }
classMeta.__index = classMeta

classMeta.__call = function(self, ...)
	return self:new(...)
end

classMeta.__newindex = function(self, index, value)
	if type(value) == "string" then -- Aliases / Compatibility
		rawset(self, index, function(this, ...)
			os.log("↑failure↓[/!\\]↑ ↑highlight↓" .. index .. "↑ is deprecated, use \z
				↑highlight↓" .. value .. "↑ instead.")
			return self[value](this, ...)
		end)
	else
		rawset(self, index, value)
	end
end

--[[@
	@name table.setNewClass
	@desc Creates a new class constructor.
	@desc If the table receives a new index with a string value, it'll create an alias.
	@returns table A metatable with constructor and alias handlers.
]]
table.setNewClass = function()
	return setmetatable({ }, classMeta)
end