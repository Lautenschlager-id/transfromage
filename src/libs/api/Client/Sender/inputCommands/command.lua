local Client = require("api/Client/init")

local ByteArray = require("classes/ByteArray")

local identifier = require("api/enum").identifier.command

--[[@
	@name sendCommand
	@desc Sends a (/)command.
	@desc /!\ Note that some unlisted commands cannot be triggered by this function.
	@param command<string> The command. (without /)
]]
Client.sendCommand = function(self, command)
	self:sendEncryptedPacket(ByteArray:new():writeUTF(command), self.mainConnection, identifier)
end