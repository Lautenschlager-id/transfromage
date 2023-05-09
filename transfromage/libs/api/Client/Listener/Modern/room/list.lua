------------------------------------------- Optimization -------------------------------------------
local string_gmatch = string.gmatch
local tonumber = tonumber
----------------------------------------------------------------------------------------------------

local onRoomList = function(self, packet, connection, identifiers)
	-- Room types
	packet:read8(packet:read8())

	local rooms, counter = { }, 0
	local roomMode = packet:read8()
	local pinned, pinnedCounter = { }, 0

	local isPinned, language, country, name
	local command, args

	local playerCount, maxPlayers, onFcMode, hasSpecialSettings

	while packet.stackLen > 0 do
		isPinned = packet:readBool()
		language = packet:readUTF()
		country = packet:readUTF()
		name = packet:readUTF()

		if isPinned then
			playerCount = packet:readUTF()

			command = packet:readUTF()
			args = packet:readUTF()

			if command == "lm" then
				for roomName, roomCount in string_gmatch(args, "&~(.-),(%d+)") do
					pinnedCounter = pinnedCounter + 1
					pinned[pinnedCounter] = {
						name = roomName,
						totalPlayers = roomCount * 1,
						language = language,
						country = country
					}
				end
			else
				pinnedCounter = pinnedCounter + 1
				pinned[pinnedCounter] = {
					name = roomName,
					totalPlayers = tonumber(playerCount) or playerCount,
					language = language,
					country = country
				}
			end
		else
			playerCount = packet:read16()
			maxPlayers = packet:read8()
			onFcMode = packet:readBool()
			hasSpecialSettings = packet:readBool()

			local hasShamanSkills, hasConsumables, hasEvents, hasCollision, hasAie, mapDuration,
				miceMass, mapRotation
			if hasSpecialSettings then
				hasShamanSkills = not packet:readBool()
				hasConsumables = not packet:readBool()
				hasEvents = not packet:readBool()
				hasCollision = packet:readBool()
				hasAie = packet:readBool()
				mapDuration = packet:read8()
				miceMass = packet:read32()
				packet:read16() -- custom room size
				mapRotation = packet:read8(packet:read8())
			end

			counter = counter + 1
			rooms[counter] = {
				name = name,
				totalPlayers = playerCount,
				maxPlayers = maxPlayers,
				onFuncorpMode = onFcMode,
				language = language,
				country = country,

				hasSpecialSettings = hasSpecialSettings,
				hasShamanSkills = hasShamanSkills,
				hasConsumables = hasConsumables,
				hasEvents = hasEvents,
				hasCollision = hasCollision,
				hasAie = hasAie,
				mapDuration = mapDuration,
				miceMass = miceMass,
				mapRotation = mapRotation
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
end

return { onRoomList, 26, 35 }
