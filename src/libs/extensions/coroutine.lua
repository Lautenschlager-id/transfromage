-- Optimization --
local coroutine_wrap = coroutine.wrap
------------------

--[[@
	@name coroutine.makef
	@desc Creates a coroutine to execute the given function.
	@param f<function> Function to be executed inside a coroutine.
	@returns function A coroutine with @f to be executed.
]]
coroutine.makef = function(f)
	return function(...)
		return coroutine_wrap(f)(...)
	end
end