local onNewLanguage = function(self, packet, connection, identifiers)
	--[[@
		@name newLanguage
		@desc Triggered when a language is changed.
		@param language<string> The code of the language.
		@param country<string> The code of the country.
		@param isRTL<boolean> Whether the language is read left to right or not.
		@param hasSpecialCharacters<boolean> Whether the language has special characters or not.
		@param font<string> The used font.
	 ]]
	local language, country = packet:readUTF(), packet:readUTF()
	local isRTL, hasSpecialCharacters = packet:readBool(), packet:readBool()
	local font = packet:readUTF()
	self.event:emit("newLanguage", language, country, isRTL, hasSpecialCharacters, font)
end

return { onNewLanguage, 176, 5 }