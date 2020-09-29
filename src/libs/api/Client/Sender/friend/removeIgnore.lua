local Client = require("Client/init")
local ByteArray = require("classes/ByteArray")

--[[@
	@name whitelistPlayer
	@desc Removes a player from the black list.
	@param playerName<string> The player name to be removed from the black list.
]]
Client.whitelistPlayer = function(self, playerName)
	self:sendTribulle(ByteArray:new():write16(44):write32(1):writeUTF(playerName))
end