# Changelogs

###### [Semantic Versioning SemVer](https://semver.org/)

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
- Added the event _ping ( )_.
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