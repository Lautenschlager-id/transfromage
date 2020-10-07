local handlePlayers = require("api/Client/utils/_internal/handlePlayers")

local onShaman = function(self, packet, connection, identifiers)
	if not handlePlayers(self) then return end

	local player = self.playerList[packet:read32()]
	if not player then return end

	player.isShaman = packet:readBool()

	self.event:emit("shaman", player, player.isShaman)
end

return {
	{ 8, 12, onShaman },
	{ 144, 7, onShaman }
}