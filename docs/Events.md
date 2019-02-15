# Events
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
>### roomChanged ( roomName, isPrivateRoom )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| roomName | `string` | The name of the room. |
>| isPrivateRoom | `boolean` | Whether the room is only accessible by the account or not. |
>
>Triggered when the account changes the room.
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
>### heartbeat ( time )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| time | `int` | The current time. |
>
>Triggered when a heartbeat is sent to the connection, every 10 seconds.
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
>### receive ( connection, packet, identifiers )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| connection | `connection` | The connection object that received the packets. |
>| packet | `byteArray` | The Byte Array object that was received. |
>| identifiers | `table` | The C, CC identifiers that were received. |
>
>Triggered when the client receives packets from the server.
>
---
>### missedPacket ( identifiers, packet )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| identifiers | `table` | The C, CC identifiers that were not handled. |
>| packet | `byteArray` | The Byte Array object with the packets that were not handled. |
>
>Triggered when an identifier is not handled by the system.
