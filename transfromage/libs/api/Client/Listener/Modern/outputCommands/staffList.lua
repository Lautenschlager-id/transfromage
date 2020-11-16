------------------------------------------- Optimization -------------------------------------------
local string_gmatch = string.gmatch
local string_sub    = string.sub
----------------------------------------------------------------------------------------------------

local onStaffList = function(self, packet, connection, identifiers) -- /mod, /mapcrew
	packet:read16() -- ?

	local data = packet:readUTF()

	local isModList = string_sub(data, 1, 5) == "$Modo"

	local namesByCommunity, commuCounter = { }, 0
	local individualNames, namesCounter = { }, 0

	for community, names in string_gmatch(data, "%[(.-)%] ([^\n]+)") do
		communities[community] = { }
		community = communities[community]

		commuCounter = 0
		for name in string_gmatch(names, "<.->(.-)</.->") do
			commuCounter = commuCounter + 1
			community[commuCounter] = name

			namesCounter = namesCounter + 1
			individualNames[namesCounter] = name
		end
	end

	--[[@
		@name staffList
		@desc Triggered when a staff list is loaded (/mod, /mapcrew).
		@param list<string> The staff list content.
	]]
	self.event:emit("staffList", isModList, namesByCommunity, individualNames)
end

return { onStaffList, 28, 5 }