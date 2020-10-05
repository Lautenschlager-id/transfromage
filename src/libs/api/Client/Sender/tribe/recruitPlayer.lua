local Client = require("api/Client/init")
local ByteArray = require("classes/ByteArray")

--[[@
	@name recruitPlayer
	@desc Sends a tribe invite to a player.
	@desc /!\ Note that this method will not cover errors if the account is not in a tribe or does not have permissions.
	@param playerName<string> The name of player to be recruited.
]]
Client.recruitPlayer = function(self, playerName)
	self:sendTribulle(ByteArray:new():write16(78):write32(1):writeUTF(playerName))
end