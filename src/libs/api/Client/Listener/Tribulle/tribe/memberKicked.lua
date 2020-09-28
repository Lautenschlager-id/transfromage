-- Optimization --
local string_toNickname = string.toNickname
------------------

local onTribeMemberKick = function(self, packet, connection, tribulleId)
	local memberName, kickerName = packet:readUTF(), packet:readUTF()

	--[[@
		@name tribeMemberKick
		@desc Triggered when a tribe member is kicked.
		@param memberName<string> The member name.
		@param kickerName<string> The name of the player who kicked the member.
	]]
	self.event:emit("tribeMemberKick", string_toNickname(memberName, true),
		string_toNickname(kickerName, true))
end

return { 93, onTribeMemberKick }