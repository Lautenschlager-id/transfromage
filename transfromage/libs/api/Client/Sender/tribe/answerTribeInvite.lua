local Client = require("api/Client/init")

local ByteArray = require("classes/ByteArray")

Client.answerTribeInvite = function(self, recruiterName, accept)
	self:sendTribulle(ByteArray:new():write16(80):write32(1):writeUTF(recruiterName)
		:writeBool(accept))
end