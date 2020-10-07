local Client = require("api/Client/init")

local ByteArray = require("classes/ByteArray")

--[[@
	@name openTribeInterface
	@desc Requests opening the tribe interface to retrieve all informations there.
	@desc /!\ Note that this method will not cover errors if the account is not in a tribe or does not have permissions.
	@param includeOfflineMembers?<boolean> Whether data from offline members should be retrieved too. @default false
]]
Client.openTribeInterface = function(self, includeOfflineMembers)
	self:sendTribulle(ByteArray:new():write16(108):write32(3):writeBool(includeOfflineMembers))
end