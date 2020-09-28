-- Optimization --
local string_toNickname = string.toNickname
------------------

local onTribeMemberLeave = function(self, packet, connection, tribulleId)
	local memberName = packet:readUTF()

	--[[@
		@name tribeMemberLeave
		@desc Triggered when a member leaves the tribe.
		@param memberName<string> The member who left the tribe.
	]]
	self.event:emit("tribeMemberLeave", string_toNickname(memberName, true))
end

return { 92, onTribeMemberLeave }