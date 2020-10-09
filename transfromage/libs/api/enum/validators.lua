------------------------------------------- Optimization -------------------------------------------
local debug_traceback = debug.traceback
local error           = error
local getmetatable    = getmetatable
local tonumber        = tonumber
local tostring        = tostring
local type            = type
----------------------------------------------------------------------------------------------------

local enum = require("./init")

--[[@
	@name _exists
	@desc Checks whether the inserted enumeration is valid or not.
	@param enumeration<enum> An enumeration object, the source of the value.
	@param value<*> The value (index or value) of the enumeration.
	@returns int,boolean Whether @value is part of @enumeration or not. It's returned 0 if the value is a value, 1 if it is an index, and false if it's not a valid enumeration.
]]
enum._exists = function(enumeration, value)
	if type(enumeration) ~= "table" or getmetatable(enumeration) ~= "enumeration" then
		return false
	end

	-- Value = 0, Index = 1
	if enumeration(value) then -- "00"
		return 0
	elseif enumeration[value] then -- "EN"
		return 1
	end
	return false
end

--[[@
	@name _validate
	@desc Validates an enumeration.
	@param enumeration<enum> An enumeration object, the source of the value.
	@param default<*> The default value of the enumeration
	@param value?<string,number> The value (index or value) of the enumeration.
	@param errorMsg?<string> The error message when the enumeration exists but is invalid.
	@returns * The value associated to the source enumeration, or the default value if nil.
]]
enum._validate = function(enumeration, default, value, errorMsg)
	value = tonumber(value) or value
	if value then
		local exists = enum._exists(enumeration, value)

		if not exists then
			return error((errorMsg or "↑failure↓[ENUM]↑ Invalid enumeration\n" ..
				tostring(debug_traceback())), -2)
		end

		if exists == 1 then
			value = enumeration[value]
		end
	else
		value = default
	end

	return value
end