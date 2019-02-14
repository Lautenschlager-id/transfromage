# Changelogs
## v.0.1.2 - 14/02/2019
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