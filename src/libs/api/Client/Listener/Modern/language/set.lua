local onLanguageSet = function(self, packet, connection, identifiers)
	--[[@
		@name languageSet
		@desc Triggered when a language is set.
		@param language<string> The code of the language.
		@param country<string> The code of the country.
		@param isRightToLeft<boolean> Whether the language is read right to left or not.
		@param hasSpecialCharacter<boolean> Whether the language has special characters or not.
	 ]]
	self.event:emit("languageSet", packet:readUTF(), packet:readUTF(), packet:readBool(),
		packet:readBool())
end

return { 176, 5, onLanguageSet }