# Private Functions
Private functions were created in the Client class because their use could compromise the functionalities of the API.

---
>### closeAll ( self )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| self | `client` | ✔ | A Client object. |
>
>Closes all the Connection objects.<br>
>Note that a new Client instance should be created instead of closing and re-opening an existent one.
>
---
>### getKeys ( self, tfmId, token )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| self | `client` | ✔ | A Client object. |
>| tfmId | `string`, `int` | ✔ | The developer's transformice id. |
>| token | `string` | ✔ | The developer's token. |
>
>Gets the connection keys in the API endpoint.
>
---
>### handleFriendData ( packet )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| packet | `byteArray` | ✔ | A Byte Array object with the data to be extracted. |
>
>Handles the data of a friend from the friend list.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table` | The data of the player. |
>
>**Table structure**:
>```Lua
>{
>	id = 0, -- The player id.
>	playerName = "", -- The player name.
>	gender = 0, -- The gender of the player. Enum in enum.gender.
>	isFriend = true, -- Whether the player has the account as a friend (added back) or not.
>	isConnected = true, -- Whether the player is online or not.
>	gameId = 0, -- The id of the game where the player is connected. Enum in enum.game.
>	roomName = "", -- The name of the room where the player is.
>	lastConnection = 0 -- Timestamp of when was the last connection of the player.
>}
>```
>
---
>### handlePlayerField ( self, packet, fieldName, eventName, methodName, fieldValue, sendValue )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| self | `client` | ✔ | A Client object. |
>| packet | `byteArray` | ✔ | A Byte Array object with the data to be extracted. |
>| fieldName | `string` | ✔ | THe name of the field to be altered. |
>| eventName | `string` | ✕ | The name of the event to be triggered. <sub>(default = "updatePlayer")</sub> |
>| methodName | `string` | ✕ | The name of the ByteArray function to be used to extract the data from @packet. <sub>(default = "readBool")</sub> |
>| fieldValue | `*` | ✕ | The value to be set to the player data @fieldName. <sub>(default = Extracted data)</sub> |
>| sendValue | `boolean` | ✕ | Whether the new value should be sent as second argument of the event or not. <sub>(default = false)</sub> |
>
>Handles the packets that alters only one player data field.
>
---
>### parsePacket ( self, connection, packet )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| self | `client` | ✔ | A Client object. |
>| connection | `connection` | ✔ | A Connection object attached to @self. |
>| packet | `byteArray` | ✔ | THe packet to be parsed. |
>
>Handles the received packets by triggering their listeners.
>
---
>### receive ( self, connectionName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| self | `client` | ✔ | A Client object. |
>| connectionName | `string` | ✔ | The name of the Connection object to get the timer attached to. |
>
>Creates a new timer attached to a connection object to receive packets and parse them.
>
---
>### sendHeartbeat ( self )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| self | `client` | ✔ | A Client object. |
>
>Sends server heartbeats/pings to the servers.
>