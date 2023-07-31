------------------------------------------- Optimization -------------------------------------------
local logMessage   = require("api/enum").logMessage
local os_log       = os.log
local rawset       = rawset
local setmetatable = setmetatable
local type         = type
----------------------------------------------------------------------------------------------------

local classMeta = { }

classMeta.__call = function(self, ...)
	return self:new(...)
end

classMeta.__newindex = function(self, index, value)
	if type(value) == "string" then
		-- class.any = "string" -- == deprecated version of class["string"], for compatibility
		rawset(self, index, function(this, ...)
			os_log(logMessage.deprecatedMethod, index, value)
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
	@param name<string> The class name to be returned on tostring's return.
	@returns table A metatable with constructor and alias handlers.
]]
table.setNewClass = function(name)
	local class = setmetatable({
		__tostring = function()
			return name
		end
	}, classMeta)
	class.__index = class

	return class
end