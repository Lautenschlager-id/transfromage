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
	
	local isPinned, language, country, name, count, max, onFcMode
	local _roomShaman, _roomConsumables, _roomCollision, _roomAIE, _roomRound, _mouseWeight, _roomSize, _roomRotation
	while packet.stackLen > 0 do
		isPinned = packet:readBool()
		language = packet:readUTF()
		country = packet:readUTF()
		name = packet:readUTF()

		if isPinned then
			count = tonumber(packet:readUTF())
			local command = packet:readUTF()
			local args = packet:readUTF()
			for roomName, roomCount in args:gmatch('&~(.-),(%d+)') do
				pinnedCounter = pinnedCounter + 1
				pinned[pinnedCounter] = {
					name = roomName,
					totalPlayers = roomCount,
					language = language,
					country = country
				}
			end
		else
			count = packet:read16()
			max = packet:read8()
			onFcMode = packet:readBool()
			onRules = packet:readBool()
			if onRules then
				_roomShaman = packet:readBool()
				_roomConsumables = packet:readBool()
				_roomCollision = packet:readBool()
				_roomAIE = packet:readBool()
				_roomRound = packet:read16()
				_mouseWeight = packet:read32()
				_roomSize = packet:read16()
				_roomRotation = packet:read8()
				if _roomRotation > 0 then
					mapRotation = {}
					for i = 1, _roomRotation do
						mapRotation[#mapRotation + 1] = packet:read8()    
					end
					_roomRotation = mapRotation
				else
					_roomRotation = false
				end
				features = {
					roomShaman = _roomShaman,
					roomConsumables = _roomConsumables,
					roomCollision = _roomCollision,
					roomAIE = _roomAIE,
					roomRound = _roomRound,
					mouseWeight = _mouseWeight,
					customRoomSize = _roomSize,
					roomRotation = _roomRotation
				}
			end
			counter = counter + 1
			rooms[counter] = {
				name = name,
				totalPlayers = count,
				maxPlayers = max,
				onFuncorpMode = onFcMode,
				language = language,
				country = country,
				onRestriction = onRules,
				rules = features
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
