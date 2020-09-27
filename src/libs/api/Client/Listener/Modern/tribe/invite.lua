local onTribeHouseInvitation = function(self, packet, connection, identifiers)
	--[[@
		@name tribeHouseInvitation
		@desc Triggered when a tribe house invitation is received.
		@param inviterName<string> The name of the player who invited the bot.
		@param inviterTribe<string> The name of the tribe that is inviting the bot.
	]]
	self.event:emit("tribeHouseInvitation", packet:readUTF(), packet:readUTF())
end

return { 16, 2, onTribeHouseInvitation }