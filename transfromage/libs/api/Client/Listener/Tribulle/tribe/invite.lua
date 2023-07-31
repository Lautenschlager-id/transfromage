------------------------------------------- Optimization -------------------------------------------
local string_toNickname = string.toNickname
----------------------------------------------------------------------------------------------------

local onTribeInvite = function(self, packet, connection, tribulleId)
	local recruiterName, tribeName = packet:readUTF(), packet:readUTF()
	self.event:emit("tribeInvite", string_toNickname(recruiterName, true), tribeName)
end

return { onTribeInvite, 86 }