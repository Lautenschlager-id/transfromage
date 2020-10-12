local Tribe = require("api/Entities/tribe/Tribe")

local onTribeDataLoaded = function(self, packet, connection, tribulleId)
	local tribe = Tribe:new(self, packet, packet:read32())

	tribe:retrieveMembers(packet)

	tribe:retrieveRoles(packet)

	--[[@
		@name tribeInterface
		@desc Triggered when the tribe interface is opened and/or when the data is updated.
		@param tribeName<string> The name of the tribe.
		@param tribeMembers<table> The members' data.
		@param tribeRoles<table> An array with the all roles name (key) and id (value).
		@param tribeHouseMap<int> The map code of the tribe house.
		@param greetingMessage<string> The tribe's greeting message.
		@param tribeId<int> The id of the tribe.
		@struct @tribeMembers {
			[i] = {
				id = 0, -- The id of the member.
				playerName = "", -- The nickname of the member.
				gender = 0, -- The member's gender. Enum in enum.gender.
				lastConnection = 0 -- Timestamp of when the member was last online.
				rolePosition = 0, -- The position of the member's role.
				roomName = "" -- The name of the room where the member currently is.
			}
		}
	]]
	self.event:emit("tribeInterface", tribe)
end

return { onTribeDataLoaded, 130 }