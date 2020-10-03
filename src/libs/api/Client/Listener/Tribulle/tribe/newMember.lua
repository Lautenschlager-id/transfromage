-- Optimization --
local string_toNickname = string.toNickname
------------------

local onNewTribeMember = function(self, packet, connection, tribulleId)
	local memberName = packet:readUTF()

	--[[@
		@name newTribeMember
		@desc Triggered when a player joins the tribe.
		@param memberName<string> The name of the new tribe member.
	]]
	self.event:emit("newTribeMember", string_toNickname(memberName, true))
end

return { onNewTribeMember, 91 }