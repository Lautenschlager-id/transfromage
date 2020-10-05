local Client = require("api/Client/init")
local ByteArray = require("classes/ByteArray")

--[[@
	@name requestBlackList
	@desc Requests the black list.
]]
Client.requestBlackList = function(self)
	self:sendTribulle(ByteArray:new():write16(46):write32(3))
end