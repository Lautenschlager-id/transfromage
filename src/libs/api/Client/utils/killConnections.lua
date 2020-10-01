--[[@
	@name closeAll
	@desc Closes all the Connection objects.
	@desc Note that a new Client instance should be created instead of closing and re-opening an existent one.
	@param self<client> A Client object.
]]
local killConnections = function(client)
	if not client.mainConnection then return end

	if client.bulleConnection then
		client.bulleConnection:close()
	end

	client.mainConnection:close()
end

return killConnections