local handlePlayers = require("api/Client/utils/_internal/handlePlayers")

local updateFlag = require("api/enum").updatePlayer.ducking

local onDuck = function(self, packet, connection, identifiers)
	if not handlePlayers(self) then return end

	local player = self.playerList[packet:read32()]
	if not player then return end

	local oldPlayerData = player:copy()
	player.isDucking = packet:readBool()

	self.event:emit("updatePlayer", player, oldPlayerData, updateFlag)
end

return { onDuck, 4, 9 }