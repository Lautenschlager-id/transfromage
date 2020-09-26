local onShaman = function(self, packet, isShaman)
	local player = self.playerList[packet:read32()]
	if not player then return end

	player.isShaman = isShaman

	self.event:emit("shaman", player, isShaman)
end

local onPlayerShaman = function(self, packet, connection, identifiers)
	onShaman(self, packet, true)
end

local onPlayerNoShaman = function(self, packet, connection, identifiers)
	onShaman(self, packet, false)
end

return {
	{ 8, 12, onPlayerShaman },
	{ 144, 7, onPlayerNoShaman }
}