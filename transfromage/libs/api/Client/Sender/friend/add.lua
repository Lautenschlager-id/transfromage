local Client = require("api/Client/init")

local ByteArray = require("classes/ByteArray")

--[[@
	@name addFriend
	@desc Adds a player to the friend list.
	@param playerName<string> The player name to be added.
]]
Client.addFriend = function(self, playerName)
	self:sendTribulle(ByteArray:new():write16(18):write32(1):writeUTF(playerName))
end