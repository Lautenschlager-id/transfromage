local Client = require("api/Client/init")

------------------------------------------- Optimization -------------------------------------------
local os_time = os.time
----------------------------------------------------------------------------------------------------

--[[@
	@name connectionTime
	@desc Gets the total time since the account was connected.
	@returns int The total time since account was logged in.
]]
Client.connectionTime = function(self)
	return os_time() - self._loginTime
end