# Changelogs
## v0.1.4 - 14/02/2019
### News
- Added _client.changeWhisperState_.
- Added _enum.whisperState_.

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