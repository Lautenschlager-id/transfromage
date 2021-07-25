local handlePlayers = require("api/Client/utils/_internal/handlePlayers")

local updateFlag = require("api/enum").updatePlayer.movement

------------------------------------------- Optimization -------------------------------------------
local math_symmetricFloor = math.symmetricFloor
----------------------------------------------------------------------------------------------------

local onPlayerMove = function(self, packet, connection, identifiers)
	if not handlePlayers(self) then return end

	local player = self.playerList[packet:read32()]
	if not player then return end

	local oldPlayerData = player:copy()

	packet:read32() -- ?

	player.movingRight = packet:readBool()
	player.movingLeft = packet:readBool()

	player.x = math_symmetricFloor(packet:read32() * 30 / 100)
	player.y = math_symmetricFloor(packet:read32() * 30 / 100)
	player.vx = packet:readSigned16() * 100 / 1000
	player.vy = packet:readSigned16() * 100 / 1000

	player.isJumping = packet:readBool()

	--[[packet:read8(2) -- ?

	if packet.stackLen > 0 then
		player.angle = packet:read32()
		player.angleVelocity = packet:read32()

		packet:read8() -- ?
	end]]

	self.event:emit("updatePlayer", player, oldPlayerData, updateFlag)
end

return { onPlayerMove, 4, 4 }