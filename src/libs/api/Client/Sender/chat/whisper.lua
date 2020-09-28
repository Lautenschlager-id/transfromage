local Client = require("Client/init")
local ByteArray = require("classes/ByteArray")

--[[@
	@name sendWhisper
	@desc Sends a whisper to a user.
	@desc /!\ Note that a message has a limit of 80 characters in the first 24 hours after the account creation, and 255 characters later. You must handle the limit yourself or the bot may get disconnected.
	@param message<string> The message.
	@param targetUser<string> The user who will receive the whisper.
]]
Client.sendWhisper = function(self, targetUser, message)
	self:sendTribulle(ByteArray:new():write16(52):write32(3):writeUTF(targetUser):writeUTF(message))
end