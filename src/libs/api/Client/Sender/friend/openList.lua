local Client = require("api/Client/init")
local ByteArray = require("classes/ByteArray")

--[[@
	@name requestFriendList
	@desc Requests the friend list.
]]
Client.requestFriendList = function(self)
	self:sendTribulle(ByteArray:new():write16(28):write32(3))
end