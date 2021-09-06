local onWhisperFail = function(self, packet, connection, tribulleId)
	packet:read32() -- ?
	local failType = packet:read8()
	local silenceMessage = packet:readUTF()

	self.event:emit("whisperFail", failType, silenceMessage)
end

return { onWhisperFail, 53 }