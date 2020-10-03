local handlePlayers = require("Client/utils/handlePlayers")

local updateFlag = require("api/enum").updatePlayer.shamanColor

local onShamanColor = function(self, packet, connection, identifiers)
	if not handlePlayers(self) then return end

	local shaman = { }

	shaman[1] = packet:read32() -- Blue
	shaman[2] = packet:read32() -- Pink

	local player, oldPlayerData
	for c = 1, 2 do
		player = self.playerList[shaman[c]]
		if player then
			oldPlayerData = player:copy()

			player[(i == 1 and "isBlueShaman" or "isPinkShaman")] = true

			self.event:emit("updatePlayer", player, oldPlayerData, updateFlag)
		end
	end
end

return { onShamanColor, 8, 11 }