local onStaffList = function(self, packet, connection, identifiers) -- /mod, /mapcrew
	packet:read16() -- ?

	--[[@
		@name staffList
		@desc Triggered when a staff list is loaded (/mod, /mapcrew).
		@param list<string> The staff list content.
	]]
	self.event:emit("staffList", packet:readUTF())
end

return {
	{ 28, 5, onStaffList }
}