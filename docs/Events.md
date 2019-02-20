# Events

Use the following structure to make events:
```Lua
client:on("event_name", function(parameters) -- replace 'on' to 'once' if you want it to be triggered only once.
	-- TODO
end)
```
---

>### ready (  )
>
>Triggered when the connection is live.
>
---
>### connection (  )
>
>Triggered when the account is logged and ready to perform actions.
>
---
>### roomMessage ( playerName, message, playerCommunity, playerId )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| playerName | `string` | The player who sent the message. (lower case) |
>| message | `string` | The message. |
>| playerCommunity | `int` | The community id of @playerName. |
>| playerId | `int` | The temporary id of @playerName. |
>
>Triggered when the room receives a new user message.
>
---
>### whisperMessage ( playerName, message, playerCommunity )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| playerName | `string` | Who sent the whisper message. (lower case) |
>| message | `string` | The message. |
>| playerCommunity | `int` | The community id of @playerName. |
>
>Triggered when the account receives a whisper.
>
---
>### chatMessage ( channelName, playerName, message, playerCommunity )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| channelName | `string` | The name of the channel. |
>| playerName | `string` | The player who sent the message. (lower case) |
>| message | `string` | The message. |
>| playerCommunity | `int` | The community id of @playerName. |
>
>Triggered when a #chat receives a new message.
>
---
>### tribeMessage ( memberName, message )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| memberName | `string` | The member who sent the message. (lower case) |
>| message | `string` | The message. |
>
>Triggered when the tribe chat receives a new message.
>
---
>### joinTribeHouse ( tribeName )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| tribeName | `string` | The name of the tribe. |
>
>Triggered when the account joins a tribe house.
>
---
>### lua ( log )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| log | `string` | The log message. |
>
>Triggered when the #lua channel receives a log message.
>
---
>### roomChanged ( roomName, isPrivateRoom )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| roomName | `string` | The name of the room. |
>| isPrivateRoom | `boolean` | Whether the room is only accessible by the account or not. |
>
>Triggered when the account changes the room.
>
---
>### profileLoaded ( data )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| data | `table` | The user profile data. |
>
>Triggered when the profile of an user is loaded.
>
>**@data structure**:
>```Lua
>{
>	playerName = "", -- The player name.
>	id = 0, -- The player id.
>	registrationDate = 0, -- The timestamp of when the account was created.
>	role = 0, -- An enum from enum.role that specifies the account's role.
>	gender = 0, -- An enum from enum.gender for the account's gender. 
>	tribeName = "", -- The name of the tribe.
>	soulmate = "", -- The name of the soulmate.
>	saves = {
>		normal = 0, -- Total saves in the normal mode.
>		hardmode = 0, -- Total saves in the hard mode.
>		divine = 0 -- Total saves in the divine mode.
>	}, -- Total saves of the account.
>	shamanCheese = 0, -- Total of cheeses gathered as shaman.
>	firsts = 0, -- Total of firsts.
>	cheeses = 0, -- Total of cheeses.
>	bootcamps = 0, -- Total of bootcamps.
>	titleId = 0, -- The id of the current title.
>	totalTitles = 0, -- Total of unlocked titles.
>	titles = {
>		[id] = 0 -- The id of the title as index, the quantity of stars as value.
>	}, -- The list of unlocked titles.
>	look = "", -- The account's outfit code.
>	level = 0, -- The account's level.
>	totalBadges = 0, -- The total of unlocked badges.
>	badges = {
>		[id] = 0 -- The id of the badge as index, the quantity as value.
>	}, -- The list of unlocked badges.
>	totalModeStats = 0, -- The total of mode statuses.
>	modeStats = {
>		[id] = {
>			progress = 0, -- The current score in the status.
>			progressLimit = 0, -- The status score limit.
>			imageId = 0 -- The image id of the status. 
>		} -- The status id.
>	}, -- The list of mode statuses.
>	orbId = 0, -- The id of the current shaman orb.
>	totalOrbs = 0, -- The total of unlocked shaman orbs.
>	orbs = {
>		[id] = true -- The id of the shaman orb as index.
>	}, -- The list of unlocked shaman orbs.
>	adventurePoints = 0 -- The total adventure points.
>}
>```
>
---
>### staffList ( list )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| list | `string` | The staff list content. |
>
>Triggered when a staff list is loaded (/mod, /mapcrew).
>
---
>### ping ( )
>
>Triggered when a server heartbeat is received.
>
---
>### heartbeat ( time )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| time | `int` | The current time. |
>
>Triggered when a heartbeat is sent to the connection, every 10 seconds.
>
---
>### disconnection ( connection )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| connection | `connection` | The connection object. |
>
>Triggered when a connection dies or fails.
>
---
>### send ( identifiers, packet )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| identifiers | `table` | The C, CC identifiers sent in the request. |
>| packet | `byteArray` | The Byte Array object that was sent. |
>
>Triggered when the client sends packets to the server.
>
---
>### missedPacket ( identifiers, packet )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| identifiers | `table` | The C, CC identifiers that were not handled. |
>| packet | `byteArray` | The Byte Array object with the packets that were not handled. |
>
>Triggered when an identifier is not handled by the system.
---
>### receive ( connection, packet, identifiers )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| connection | `connection` | The connection object that received the packets. |
>| packet | `byteArray` | The Byte Array object that was received. |
>| identifiers | `table` | The C, CC identifiers that were received. |
>
>Triggered when the client receives packets from the server.
>