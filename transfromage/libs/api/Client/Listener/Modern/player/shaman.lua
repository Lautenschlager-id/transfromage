local handlePlayers = require("api/Client/utils/_internal/handlePlayers")

local onShaman = function(self, packet, connection, identifiers)
	if not handlePlayers(self) then return end

	local player = self.playerList[packet:read32()]
	if not player then return end

	player.isShaman = identifiers[1] == 8 -- 8 = promote, 144 = demote

	self.event:emit("shaman", player, player.isShaman)
end

return {
	{ onShaman, 8, 12 },
	{ onShaman, 144, 7 }
}