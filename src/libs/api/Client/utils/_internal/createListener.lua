local createListener = function(listener, f, C, CC)
	if not CC then
		listener[C] = f
		return
	end

	if not listener[C] then
		listener[C] = { }
	end
	listener[C][CC] = f
end

return createListener