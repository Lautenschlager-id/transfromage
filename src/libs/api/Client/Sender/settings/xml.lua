local Client = require("Client/init")

--[[@
	@name processXml
	@desc Toggles the field _\_process\_xml_ of the instance.
	@desc If 'true', the XML will be processed in the event _newGame_.
	@param process?<boolean> Whether map XMLs should be processed.
	@returns boolean Whether map XMLs will be processed.
]]
Client.decryptXML = function(self, decrypt)
	if decrypt == nil then
		self._decryptXML = not self._decryptXML
	else
		self._decryptXML = decrypt
	end

	return self._decryptXML
end