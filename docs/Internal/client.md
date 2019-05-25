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
>Gets the connection keys in the API endpoint.<br>
>This function is destroyed when [start](../Client.md#clientstart--tfmid-token-) is called.
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