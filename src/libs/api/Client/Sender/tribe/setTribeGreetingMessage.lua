local Client = require("Client/init")
local ByteArray = require("classes/ByteArray")

--[[@
	@name setTribeGreetingMessage
	@desc Changes the greeting message of the tribe.
	@desc /!\ Note that this method will not cover errors if the account is not in a tribe or does not have permissions.
	@param message<string> The message.
]]
Client.setTribeGreetingMessage = function(self, message)
	self:sendTribulle(ByteArray:new():write16(98):write32(1):writeUTF(message))
end