local handlePlayers = require("Client/utils/handlePlayers")

local updateFlag = require("api/enum").updatePlayer.facingDirection

local onFacingDirection = function()
	if not handlePlayers(self) then return end

	local player = self.playerList[packet:read32()]
	if not player then return end

	local oldPlayerData = player:copy()
	player.isFacingRight = packet:readBool()

	self.event:emit("updatePlayer", player, oldPlayerData, updateFlag)
end

return {
	{ 4, 6, onFacingDirection },
	{ 4, 10, onFacingDirection }
}