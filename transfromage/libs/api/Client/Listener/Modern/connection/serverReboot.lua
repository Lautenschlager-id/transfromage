local onServerReboot = function(self, packet, connection, identifiers)
	--[[@
		@name serverReboot
		@desc Triggered when the server is going to be rebooted.
		@param remainingTime<int> Remaining time in milliseconds before the reboot.
	]]
	self.event:emit("serverReboot", packet:read32())
end

return { onServerReboot, 28, 88 }