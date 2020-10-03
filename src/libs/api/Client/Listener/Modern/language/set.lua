local onLanguageSet = function(self, packet, connection, identifiers)
	--[[@
		@name languageSet
		@desc Triggered when a language is set.
		@param language<string> The code of the language.
		@param country<string> The code of the country.
		@param isRightToLeft<boolean> Whether the language is read right to left or not.
		@param hasSpecialCharacter<boolean> Whether the language has special characters or not.
		@param connection<connection> The connection in which the language has been set.
	 ]]
	self.event:emit("languageSet", packet:readUTF(), packet:readUTF(), packet:readBool(),
		packet:readBool(), connection)
end

return { onLanguageSet, 176, 5 }