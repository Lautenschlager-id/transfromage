local onNewLanguage = function(self, packet, connection, identifiers)
	--[[@
		@name newLanguage
		@desc Triggered when a language is changed.
		@param language<string> The code of the language.
		@param country<string> The code of the country.
		@param readRight<boolean> Whether the language is read left to right or not.
		@param readSpecialChar<boolean> Whether the language has special characters or not.
	 ]]
	local language, country = packet:readUTF(), packet:readUTF()
	local readRight, readSpecialChar = packet:readBool(), packet:readBool()
	self.event:emit("newLanguage", language, country, readRight, readSpecialChar)
end

return { onNewLanguage, 176, 5 }