local Client = require("api/Client/init")

------------------------------------------- Optimization -------------------------------------------
local bulleIdentifier = require("api/enum").identifier.bulle
----------------------------------------------------------------------------------------------------

Client.sendTribulle = function(self, packet)
	self.mainConnection:send(bulleIdentifier, packet)
end