local Client = require("Client/init")
local ByteArray = require("classes/ByteArray")

--[[@
	@name setTribeMemberRole
	@desc Sets the role of a member in the tribe.
	@desc /!\ Note that this method will not cover errors if the account is not in a tribe or does not have permissions.
	@param memberName<string> The name of the member to get the role.
	@param roleId<int> The role id. (starts from 0, the initial role, and goes until the Chief role)
]]
Client.setTribeMemberRole = function(self, memberName, roleId)
	self:sendTribulle(ByteArray:new():write16(112):write32(1):writeUTF(memberName):write8(roleId))
end