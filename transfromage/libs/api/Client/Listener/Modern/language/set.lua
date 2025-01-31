local onLanguageSet = function(self, packet, connection, identifiers)
	--[[@
		@name languageSet
		@desc Triggered when a language is set.
		@param language<string> The code of the language.
		@param country<string> The code of the country.
		@param isRightToLeft<boolean> Whether the language is read right to left or not.
		@param hasSpecialCharacters<boolean> Whether the language has special characters or not.
		@param font<string> The used font.
		@param connection<connection> The connection in which the language has been set.
	 ]]
	local language, country = packet:readUTF(), packet:readUTF()
	local isRightToLeft, hasSpecialCharacters = packet:readBool(), packet:readBool()
	local font = packet:readUTF()
	self.event:emit("languageSet", language, country, isRightToLeft, hasSpecialCharacters, font,
		connection)
end

return { onLanguageSet, 176, 5 }