# Changelogs
## v0.5.0 - 20/02/2019
### News
- Added _client.emit_.
- Now the _cipher_ class can be used from the require. `require('transfromage').encode`
- Added the event _staffList ( list )_.
- Added _client.insertReceiveFunction_.
- Added a new parameter `timeout` in _client.connect_.

### Fixes
- The function _string.getBytes_ could if it was too big. 
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