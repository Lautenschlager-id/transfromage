local Client = require("Client/init")
local ByteArray = require("classes/ByteArray")

--[[@
	@name blacklistPlayer
	@desc Adds a player to the black list.
	@param playerName<string> The player name to be added.
]]
Client.blacklistPlayer = function(self, playerName)
	self:sendTribulle(ByteArray:new():write16(42):write32(1):writeUTF(playerName))
end