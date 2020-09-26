# Changelogs

###### [Semantic Versioning SemVer](https://semver.org/)
## v9.0.0 - ?
## Changes
- When a player becomes shaman, the event _shaman_ will be triggered instead of _updatePlayer_.
- _connection_ has been renamed to _Connection_.
- _Translation.download_ is not the class' constructor.
- _Translation_ is now a class.
- _translation_ has been renamed to _Translation_.
- _encode_ is not a class anymore.
- _buffer_ has been renamed to _Buffer_.
- _bitwise_ has been renamed to _bit64_.
- _byteArray_ has been renamed to _ByteArray_.

## v8.0.0 - 05/09/2020
## News
- The _ready_ event now receives a new parameter _language_ which in the future may vary.

## Changes
- Handle language receive/send due to internal changes of the game.

## v7.1.0 - 01/09/2020
## Changes
- Changed how translations were getting split due to internal changes of the game.
- _string.split_ has a new implementation. Now it receives a separator instead of a negation pattern. Example: '%S+ is now '%s'.<br>
You still can use the old version with _string.split2_ by using the following chunk:
```Lua
--[[@
	@name string.split2
	@desc Splits a string into parts based on a pattern.
	@param str<string> The string to be split.
	@param pat<string> The pattern to split the string. Note that it doesn't auto-include '[^%s]'
	@returns table The data of the split string.
]]
string.split2 = function(str, pat)
	local out, counter = { }, 0

	for v in string.gmatch(str, pat) do
		counter = counter + 1
		out[counter] = tonumber(v) or v
	end

	return out
end
```

## v7.0.1 - 19/08/2020
## Fixes
- _byteArray.write24_'s alias _byteArray.writeInt_ was named _byteArray.writeWrite_. Same for read.

## v7.0.0 - 10/06/2020
## Changes
- Change keys endpoint
- Remove mapArray because it's not used anymore
- ByteArray performance slightly improved

## v6.1.0 - 28/05/2020
## News
- Added method _client.waitFor_ to await an event emission.
```Lua
client:on("whisperMessage", function(playerName, message)
	if message == "cheese" then
		client:sendCommand("profile " .. playerName)

		local success, playerData = client:waitFor("profileLoaded", 1000, function(playerData)
			return playerData.playerName == playerName
		end)

		if success then
			client:sendWhisper(playerName, "You have " .. playerData.cheese .. " cheese!")
		end
	end
end)
```
- New IDs in _enum.identifier_.
- Added event _tribeInterface ( tribeName, tribeMembers, tribeRanks, tribeHouseMap, greetingMessage, tribeId)_.
- Added method _client.openTribeInterface_.
- Added method _client.acceptTribeHouseInvitation_.
- Added event _tribeHouseInvitation ( inviterName, inviterTribe )_.
- Added event _serverReboot ( msTime )_.
- Added method _client.enterPrivateRoom_.

## Changes
- ByteArray is now read-only or write-only. You cannot mix it. With that, read functions got \~35x faster.

## Fixes
- Connection wouldn't reset properly if needed. (Fix _connectionFailed_ reconnection)
- Closing the command prompt/terminal or process should close all pending connections correctly now, thus avoiding firewall bans.

## v6.0.0 - 30/04/2020
## News
- New IDs in _enum.roomMode_.

## Changes
- Switching bulles won't extract the bulle id anymore, but _uid_ and _pid_.
- Removed parameter _bulleId_ from the event _switchBulleConnection_.
- Ports are now set in (44, 1), since this information is received there.
- Switched _enum.roomMode.defilante_ with _enum.roomMode.music_.

## v5.0.0 - 29/04/2020
## News
- Added method _client.setTribeGreetingMessage_
- New event _playerEmoticon ( playerData, emoticon )_.

## Changes
- PacketID is not set on login anymore.
- Errors will not be thrown anymore when getKey cannot retrieve data from the endpoint if the account is a bot.

## v4.0.0 - 28/03/2020
## News
- Added the internal function _client.stopHandlingPlayers_.
- Allow UserBots to use the API.
- Two new fields in _client_ object: _\_hasSpecialRole_ and _\_updateSettings_.
- Two new parameters in _client.new_: _hasSpecialRole_ and _updateSettings_.
- Update IP and Ports with the endpoint content.
- Improve byteArray's performance.
- New enum _url_.

## Changes
- _client._who_fingerprint_ has been renamed to _client._whoFingerprint_.
- _client._who_list_ has been renamed to _client._whoList_.
- _client._process_xml_ has been renamed to _client._processXml_.
- _client._handle_players_ has been renamed to _client._handlePlayers.
- _encode.lua_ is now a class.
	- _encode.getPasswordHash_ is a static function.
	- _encode.btea_ and _encode.xorCipher_ are now class functions.
	- _setPacketKeys_ has been removed.

## v3.0.0 - 22/02/2020
## News
- New event _connectionInfo ( playerData, friendList, soulmate, blackList, tribeData )_.
- New parameter added to _switchBulleConnection_: _serverTimestamp_.
- The _roomList_ event now has the community value for each table of _@rooms_/_@pinned_.

## Changes
- New protocol system for the new protocol system of the game.
- Minor optimizations in the code.

## v2.5.0 - 09/02/2020
## News
- Added function _byteArray.readSigned16_.

## Changes
- The translation methods will now return booleans based on whether the action happened or not.

## Fixes
- The autoupdater system should be fixed.
- Likes of cafe messages were not working properly due to unsigned shorts.

## v2.4.0 - 24/12/2019
## News
- Added new parameters in the event _ready_: `onlinePlayers`, `community`, `country`.
- Added new parameters in the event _connection_: `playerName`, `community`, `playerId`, `playedTime`.
- Added the event _bulleSwitchConnection ( bulleId, bulleIp )_

### Fixes
- Changing room would disconnect the bots due to a bulle connection change that has been implemented internally in the game.

## v2.3.0 - 21/12/2019
### News
- Now you can call the client constructor passing the parameters `tfmId` and `token` so that it automatically calls the start function.

### Fixes
- The method _client.openCafe_ would not work correctly.
- Fixed weird require behavior depending on the operational system. ~~(i hope)~~

## v2.2.0 - 11/10/2019
### News
- Added the event _playerEmote( playerData, emote, flag )_.

### Fixes
- The _append_ parameter in the insertion methods were not working.

## v2.1.1 - 20/07/2019
### Fixes
- Removed the handler of lit OS glitch. Lua's require, **BURN IN HELL**

## v2.1.0 - 20/07/2019
### News
- _\_\_tostring_ metamethod in byteArray.

### Fixes
- Fixed some login issues due to the new connection system. (google, facebook, etc)

## v2.0.1 - 12/07/2019
### Fixes
- Windows vs Linux require behavior was in conflict. Now it handles both.

## v2.0.0 - 10/07/2019
### Changes
- Transformice's IP and Ports have changed. All previous versions won't work unless these values get edited in the enumerations.
```
New IP = 94.23.193.229
New ports = 13801, 11801, 12801, 14801
```

### Fixes
- _connection.send_ would trigger an error when the socket was closed.

## v1.7.2 - 09/07/2019
### Fixes
- Small glitch in the alias system.

## v1.7.1 - 09/07/2019
### Fixes
- Pray for the connection memory leak, an undo was necessary...

## v1.7.0 - 09/07/2019
### News
- Added _transfromage.version_.
- Added the metamethod \_\_pairs in _client.playerList_ so it can iter over string indexes only.
```Lua
-- How to use client.playerList

-- An event that returns a player id
client:on("removeFriend", function(playerId)
	if client.playerList[playerId] then
		print("You removed the player '" .. client.playerList[playerId].playerName .. "' from your friend list. This player is in your room.")
	end
end)

-- Iter over the players
local names = { }
for player = 1, #client.playerList do
	names[player] = client.playerList[player].playerName
end
print("Players in the room: " .. table.concat(names, ", "))

-- Iter over their names (same code as above, but with an extra comma :)
print("Players in the room: ")
for k, v in pairs(client.playerList) do -- pairs is necessary to trigger __pairs
	io.write(v.playerName .. ", ")
end
```
- Added two helpers for readability and to avoid using private fields: _client.handlePlayers_, client.processXml_
- Added a small alias / compatibility system through _table.setNewClass_.

### Changes
- Renamed _client.closeAll_ to _client.disconnect_, but kept compatibility.

### Fixes
- Fixed a possible memory leak from _connection_. :thinking:
- _playerList[i].\_pos_ is not to as stable as it seemed to be, a fix might come soon but for now it'll ignore invalid indexes.

### Fix
- _client.playerList_ wouldn't refresh when the account changed the room.

## v1.6.1 - 02/07/2019
### Fixes
- _bArray.writeBigUtf_ would not work when the input was string.

## v1.6.0 - 29/06/2019
### News
- Added _enum.game_.
- Added the private function _handleFriendData_.
- Added the event _removeFriend ( playerId )_.
- Added the event _newFriend ( friend )_.
- Added the event _blackList ( blackList )_.
- Added _client.whitelistPlayer_.
- Added _client.blacklistPlayer_.
- Added _client.removeFriend_.
- Added _client.addFriend_.
- Added _client.requestBlackList_.
- Added a new data value for the parameters of the event _friendList_, `gameId`.

### Fixes
- Now the field from the handleFriendData _playerName_ has its nickname normalized with _string.toNickname_.

## v1.5.1 - 26/06/2019
## Fixes
- _client.\_process\_xml_ was set to true as default.

## v1.5.0 - 22/06/2019
## News
- Added the event _connectionFailed ( )_.
- Added a new parameter in _translation.download_, now it accepts a function to execute after the file download.

## Changes
- _client.start_ can now be called more than once.
- Now the internal function _getKeys_ is not deleted after client.start is called.

## Fixes
- The _timed out_ constant problems were reduced.
- Now the field from the event profileLoaded _soulmate_ has its nickname normalized with _string.toNickname_.

## v1.4.0 - 07/06/2019
## News
- Added the event _friendList ( friendList, soulmate )_.
- Added _client.requestFriendList_.

## v1.3.0 - 02/06/2019
## News
- Added _translation.set_.

### Changes
- Added optimization variables.

### Fixes
- _translation.free_ wouldn't work correctly when both whitelist parameters were set simultaneously.

## v1.2.0 - 25/05/2019
### News
- Renamed the private function _coroutineFunction_ to _coroutine.makef_.
- Added _translation.download_, _translation.get_ and _translation.free_.
- Added the file _translation.lua_.
- Added _string.utf8_.

### Changes
- _table.copy_ now cover tables.

### Fixes
- Now invalid enumerations, using an error handler that ignores low level ones, won't break the client functions anymore.

## v1.1.0 - 22/05/2019
### News
- Added the internal function _client.coroutineFunction_.

### Changes
- All insert functions now execute automatic coroutine callbacks. (@f is now coroutinized).


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
- Renamed the tables _trib_, _oldPkt_, and _exec_ in Client.lua. They are now called _tribulleListener_, _oldPacketListener_ and _packetListener_, respectively.
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