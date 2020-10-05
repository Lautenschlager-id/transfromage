local Client = require("api/Client/init")
local ByteArray = require("classes/ByteArray")

--[[@
	@name removeFriend
	@desc Removes a player from the friend list.
	@param playerName<string> The player name to be removed from the friend list.
]]
Client.removeFriend = function(self, playerName)
	self:sendTribulle(ByteArray:new():write16(20):write32(1):writeUTF(playerName))
end