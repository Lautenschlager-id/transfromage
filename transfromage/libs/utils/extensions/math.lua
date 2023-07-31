------------------------------------------- Optimization -------------------------------------------
local math_ceil  = math.ceil
local math_floor = math.floor
----------------------------------------------------------------------------------------------------

--[[@
	@name math.normalizePoint
	@desc Normalizes a Transformice coordinate point value.
	@param n<number> The coordinate point value.
	@returns int The normalized coordinate point value.
]]
math.symmetricFloor = function(n)
	return (n > 0 and math_ceil(n) or n < 0 and math_floor(n) or n)
end