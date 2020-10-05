local Client = require("api/Client/init")
local ByteArray = require("classes/ByteArray")

--[[@
	@name kickTribeMember
	@desc Kicks a member from the tribe.
	@desc /!\ Note that this method will not cover errors if the account is not in a tribe or does not have permissions.
	@param memberName<string> The name of the member to be kicked.
]]
Client.kickTribeMember = function(self, memberName)
	self:sendTribulle(ByteArray:new():write16(104):write32(1):writeUTF(memberName))
end