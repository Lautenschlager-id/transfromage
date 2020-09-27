local Tribe = require("Entities/tribe/tribe")

local triggerFriendList = require("Tribulle/friend/list")[2]
local triggerBlackList = require("Tribulle/friend/blacklist")[2]

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

return { 3, onAccountDataLoaded }