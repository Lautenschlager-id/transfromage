local Tribe = require("api/Entities/tribe/Tribe")
local triggerFriendList = require("api/Client/Listener/Tribulle/friend/list")[1]
local triggerBlackList = require("api/Client/Listener/Tribulle/friend/blacklist")[1]

local onAccountDataLoaded = function(self, packet, connection, tribulleId)
	local player = { }
	player.gender = packet:read8()
	player.id = packet:read32()

	triggerFriendList(self, packet, connection, tribulleId)

	triggerBlackList(self, packet, connection, tribulleId)

	local tribe = Tribe:new(packet) -- ?

	local tribeMember = { }
	tribeMember.rank = packet:readUTF()
	tribeMember.rankPermissions = packet:read32()

	self.event:emit("accountDataLoaded", player, tribeMember)
end

return { onAccountDataLoaded, 3 }