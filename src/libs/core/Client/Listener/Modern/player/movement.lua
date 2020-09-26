local updateFlag = require("core/enum").updatePlayer.movement

-- Optimization --
local math_normalizePoint = math.normalizePoint
------------------

local onPlayerMove = function(self, packet, connection, identifiers)
	local player = self.playerList[packet:read32()]
	if not player then return end

	local oldPlayerData = player:copy()

	player.movingRight = packet:readBool()
	player.movingLeft = packet:readBool()

	player.x = math_normalizePoint(packet:read32())
	player.y = math_normalizePoint(packet:read32())
	player.vx = packet:read16()
	player.vy = packet:read16()

	player.isJumping = packet:readBool()

	self.event:emit("updatePlayer", player, oldPlayerData, updateFlag)
end

return { 4, 4, onPlayerMove }