local Client = require("api/Client/init")

local ByteArray = require("classes/ByteArray")

Client.leaveTribe = function(self)
	self:sendTribulle(ByteArray:new():write16(82):write32(1))
end