-- Optimization --
local string_toNickname = string.toNickname
------------------

local onTribeMemberKick = function(self, packet, connection, tribulleId)
	local setterName, memberName, role = packet:readUTF(), packet:readUTF(), packet:readUTF()

	--[[@
		@name tribeMemberGetRole
		@desc Triggered when a tribe member gets a role.
		@param memberName<string> The member name.
		@param setterName<string> The name of the player who set the role.
		@param role<string> The role name.
	]]
	self.event:emit("tribeMemberGetRole", string_toNickname(memberName, true),
		string_toNickname(setterName, true), role)
end

return { onTribeMemberKick, 124 }