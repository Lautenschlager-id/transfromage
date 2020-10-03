-- Optimization --
local tonumber = tonumber
------------------

local onRoomList = function(self, packet, connection, identifiers)
	 -- Room types
	packet:read8(packet:read8())

	local rooms, counter = { }, 0
	local roomMode = packet:read8()
	local pinned, pinnedCounter = { }, 0

	local isPinned, language, country, name, count, max, onFcMode
	while packet.stackLen > 0 do
		isPinned = packet:readBool()
		language = packet:readUTF()
		country = packet:readUTF()
		name = packet:readUTF()

		if isPinned then
			count = tonumber(packet:readUTF())
			local command = packet:readUTF()
			local args = packet:readUTF()
			for roomName, roomCount in args:gmatch('&~(.-),(%d+)') do -- improve
				pinnedCounter = pinnedCounter + 1
				pinned[pinnedCounter] = {
					name = roomName,
					totalPlayers = roomCount * 1,
					language = language,
					country = country
				}
			end
		else
			count = packet:read16()
			max = packet:read8()
			onFcMode = packet:readBool()

			counter = counter + 1
			rooms[counter] = {
				name = name,
				totalPlayers = count,
				maxPlayers = max,
				onFuncorpMode = onFcMode,
				language = language,
				country = country
			}
		end
	end

	--[[@
		@name roomList
		@desc Triggered when the room list of a mode is loaded.
		@param roomMode<int> The id of the room mode.
		@param rooms<table> The data of the rooms in the list.
		@param pinned<tablet> The data of the pinned objects in the list.
		@struct @rooms {
			[i] = {
				name = "", -- The name of the room.
				totalPlayers = 0, -- Number of players in the room.
				maxPlayers = 0, -- Maximum Number of players the room can get.
				onFuncorpMode = false, -- Whether the room is having a funcorp event (orange name) or not.
				language = int, -- Language of room
				country = int, -- Country of room
			}
		}
		@struct @pinned {
			[i] = {
				name = "", -- The name of the room.
				totalPlayers = 0, -- Number of players in the room.
				language = int, -- Language of room
				country = int, -- Country of room
			}
		}
	]]
	self.event:emit("roomList", roomMode, rooms, pinned)
end,

return { onRoomList, 26, 35 }