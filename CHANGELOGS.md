# Changelogs

###### [Semantic Versioning SemVer](https://semver.org/)

## v1.1.0 - 22/05/2019
### News
- Added the internal function _client.coroutineFunction_.

### Changes
- All insert functions now execute automatic coroutine callbacks. (@f is now coroutinezed).


## v1.0.0 - 22/05/2019
### News
- Added the function _os.log_.
- Added the function _connection.close_.
- Added the function _client.reloadCafe_.
- The field _client.\_cafe_ was renamed to _client.cafe_.
- Implemented error system (low and high error) with the enum of _enum.errorLevel_. Now you can rewrite the function _error_ to handle low and high errors differently. Example:
```Lua
do
	local err = error
	error = function(message, level)
		if level == transfromage.enum.errorLevel.low then
			return os.log("↑failure↓ERROR↑ " .. message) -- Colorful print with the FAILURE warning.
		else
			return error(message, level)
		end
	end
end
```
- Added internal function _client.handlePlayerField_.
- Added a new parameter `append` in the listener functions.
- Added _table.copy_.
- Added the event _refreshPlayerList ( playerList )_.
- Added the event _updatePlayer ( playerData, oldPlayerData )_.
```Lua
-- All the facilities events (playerGetCheese, playerVampire, etc) can be hard-coded using this main-event.
-- Example:
client:on("updatePlayer", playerData, oldPlayerData)
	if playerData.hasCheese and not oldPlayerData.hasCheese then
		client:emit("playerGetCheese", playerData, true)
	elseif oldPlayerData.hasCheese and not playerData.hasCheese then
		client:emit("playerGetCheese", playerData, false)
	end		
end)
```
- Added the event _newPlayer ( playerData )_.
- Added the event _playerGetCheese ( playerData, hasCheese )_.
- Added the event _playerVampire ( playerData, isVampire )_.
- Added the event _playerWon ( playerData, position, timeElapsed )_.
- Added the event _playerLeft ( playerData )_.
- Added the event _playerDied ( playerData )_.
- Added _math.normalizePoint_.
- Added _enum.errorLevel_.
- Added _table.setNewClass_.
- Added _enum.error_.
- Added _enum.\_validate_.

### Changes
- The sequence order of parameters in the listener functions have changed.
	- insertTribulleListener's f → (packet, connection, tribulleId)
	- insertOldPacketListener's f → (data, connection, oldIdentifiers)
	- insertPacketListener's f → (packet, connection, identifiers)
- Now you don't need to send _client.openCafe_ to reload it. Use _client.reloadCafe_ instead.
- Renamed the tables _trib_, _oldPkt_, and _exec_ in Client.lua. They are now called _tribulleListener_, _oldPacketListener_ and _packetListener_, respectivelly..
- Renamed the class _connectionHandler_ to _connection_.
- Renamed the enum _emote.:D_ to _emote.laugh_, due to facilities. **No compatibility maintained.**
- Renamed the enum _identifier.message_ to _identifier.bulle_, since it was a grotesque mistake since the beginning. **No compatibility maintained.**
- Renamed the enum _identifier.bulle_ to _identifier.bulleConnection_. **No compatibility maintained** because it was an internal enum.
- Added the function _client.closeAll_, a brute-force to trigger the real and private _closeAll_ function.
- Removed _client.gamePacketKeys_. It was never used.
- The functions _client.parsePacket_, _client.receive_, _client.getKeys_, _client.sendHeartbeat_, _client.closeAll_ are now private, since their use could compromise the functionalities of the API.
- Renamed the function _encode.encodeChunks_ to _encode.btea_. **No compatibility maintained.**
- Renamed the file _cipher_ to _encode_.
- The following client fields were renamed to private fields:
	- mainLoop → \_mainLoop
	- bulleLoop → \_bulleLoop
	- receivedAuthkey → \_receivedAuthkey
	- gameVersion → \_gameVersion
	- gameConnectionKey → \_gameConnectionKey
	- gameIdentificationKeys → \_gameIdentificationKeys
	- gameMsgKeys → \_gameMsgKeys
- Renamed _enum.\_checkEnum_ to _enum.\_exists_. **No compatibility maintained** because it was an internal function.
- **End of compatibility** of _enum.\_enum_. Use the constructor _enum()_ instead.
- The sequence of the parameters in the events _missedPacket_, _missedTribulle_, and _missedOldPacket_ have all changed. Now, the _connection_ parameter is the last one.
- _client.on_ and _client.once_ now have automatic coroutine callbacks.

### Fixes
- The event _disconnection_ would trigger twice when the main socket got disconnected.
- _client.\_connectionTime_ was wrongly set before the login.
- _table.join_ was broken.

## v0.10.0 - 11/05/2019
### News
- Added the event _unreadCafeMessage ( topicId, topic )_.
```Lua
-- Usually should be used as
client:on("unreadCafeMessage", function(topicId, topic)
	client:openCafeTopic(topicId)
end)
```
- Added _client.openCafeTopic_.
- Added _client.createCafeTopic_.
- Added _client.likeCafeMessage_.
- Added _client.sendCafeMessage_.
```Lua
-- Tools for sending messages
local quoteCafeMessage = function(message)
	return "> @" .. message.author .. "\r> " + message.content + "\r\r"
end

local replyCafeMessage = function(message, content)
	client:sendCafeMessage(message.topicId, quoteCafeMessage(message.content) .. content)
end
```
- Added the event _cafeTopicMessage ( message, topic )_.
- Added the event _cafeTopicLoad ( topic )_.
- Added the event _cafeTopicList ( data )_.
- Added _client.openCafe_.
- Added the event _roomList ( roomMode, rooms, pinned )_.
- Added _enum.roomMode_.
- Added _client.requestRoomList_.
- Added _client.insertOldPacketListener_.
- Added the event _missedOldPacket ( connection, identifiers, packet )_.
- Now the API supports old packets (1, 1).

### Changes
- The insertFuction functions were renamed. However the compatibility was kept. (Please, open an issue if you find any problem related to it)
	- insertReceiveFunction  → insertPacketListener
	- insertTribulleFunction → insertTribulleListener

### Fixes
- The event _missedPacket_ now receives the parameter _connection_.

## v0.9.2 - 06/04/2019
### Fixes
- The event _tribeMemberGetRole_ was passing the parameters memberName and setterName in a wrong order.

## v0.9.1 - 05/04/2019
### Fixes
- It was missing some normalization for player names and uncoded strings in some events.

## v0.9.0 - 05/04/2019
### News
- Added _client.setTribeMemberRole_.
- Added the event _tribeMemberGetRole ( memberName, setterName, role )_.
- Added the event _friendConnection ( playerName )_.
- Added the event _friendDisconnection ( playerName )_.
- Added the event _tribeMemberConnection ( memberName )_.
- Added the event _tribeMemberDisconnection ( memberName )_.
- Added the event _tribeMemberKick ( memberName, kickerName )_.
- Added _client.kickTribeMember_.

### Changes
- The documentation is now reorganised.
- Events are not documented in the source files.
- The order of the port numbers has been changed aiming better connections.

## v0.8.1 - 04/04/2019
### Fixes
- Due to memory consumption the variable `_process_xml` is now exposed so you can enable or disable the XML processes. Default value is true. Set it as false if you are not using the event _newGame_.
```Lua
client._process_xml = false
```

## v0.8.0 - 04/04/2019
### News
- Added the event _newGame ( map )_.
- Added _client.recruitPlayer_.

### Changes
- The ByteArray functions were renamed. However the compatibility was kept. (Please, open an issue if you find any problem related to it)
	- readByte   → read8
	- write8     → write8
	- readShort  → read16
	- writeShort → write16
	- readInt    → read24
	- writeInt   → write24
	- readLong   → read32
	- writeLong  → write32

### Fixes
- The emoticon enumeration was wrong.

## v0.7.0 - 22/03/2019
### News
- Added the event _tribeMemberLeave ( memberName )_.
- Added the event _newTribeMember ( memberName )_.
- Added the event _time ( time )_.
- Added _client.connectionTime_.

## v0.6.0 - 24/02/2019
### News
- Added the function _string.toNickname ( str, checkDiscriminator )_.
- Added the event _chatWho ( chatName, data )_.
- Added the event _missedTribulle ( connection, tribulleId, packet  )_.
- Added _client.insertTribulleFunction_.
- Added _client.chatWho_.
- Added the event _tribeMessage ( memberName, message )_.
- Added _client.sendTribeMessage_.

### Changes
- The order of parameters of the _receive_ event changed. ( connection, identifiers, packet )
- The private function _fixEntity_ is now _string.fixEntity_.

### Changes
- Renamed the file `byteArray.lua` to `bArray.lua` due to Heroku compatibility issues.

### Fixes
- Improved the packet struct of _client.loadLua_.

## v0.5.0 - 20/02/2019
### News
- Added _client.emit_.
- Now the _cipher_ class can be used from the require. `require('transfromage').encode`
- Added the event _staffList ( list )_.
- Added _client.insertReceiveFunction_.
- Added a new parameter `timeout` in _client.connect_.

### Fixes
- The function _string.getBytes_ could break if it was too big. 
- When someone sent the character `<` it was accidentally replaced by `>`. 

## v0.4.0 - 17/02/2019
### News
- Added a new update system: `semiautoupdate`, that asks for permission before updating the API.
- Added _client.playEmoticon_.
- Added _client.playEmote_.
- Added the event _profileLoaded ( data )_.

### Fixes
- Fixed an enumeration problem in _changeWhisperState_.
- Added the message error when the endpoint keys fail.
- Added the `time` argument in the ping event.

## v0.3.0 - 17/02/2019
### News
- Added the event _ping (  )_.
- Added the event _lua ( log )_.

### Fixes
- Fixed `community` and `chatCommunity` enums.
- The events will translate every `&amp;` to `&` now.

## v0.2.0 - 15/02/2019
### News
- Added _client.loadLua_.
- Added the event _tribeMessage ( memberName, message )_.
- Added _client.sendTribeMessage_.
- Added _client.changeWhisperState_.
- Added _enum.whisperState_.

### Fixes
- The events will translate every `&lt;` to `<` now.

## v0.1.4 - 14/02/2019
### Changes
- Improved the error messages when an enum is not provided correctly in the functions.

### Fixes
- Initial room was set to `nil` instead of `*#bolodefchoco` if no value was provided.

## v0.1.3 - 14/02/2019
### News
- Now the _byteArray_ class can be used from the require. `require('transfromage').byteArray`

### Fixes
- Now the _connection_ event is triggered after 5s since the login, not 2s. It prevents many bulle bugs.

## v0.1.2 - 14/02/2019
### News
- Added an error message when the tfmkey or token parameters are invalid in `Client.start`.

### Fixes
- byteArray.writeBool was incorrect.
- File byteArray was named bytearray and it could throw an error without the luvit require module.
- The private event *_socketConnection* was receiving a nil value as parameter. (port)

## v0.1.1 - 13/02/2019
### Fixes
- The `autoupdate` system was not working.

## v0.1.0 - 13/02/2019
#### News
- Release version. Connection stable.