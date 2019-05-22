# Connection
Handles the connection with the Transformice's servers.

---
>### connection:new ( name, event )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| name | `string` | ✔ | The connection name, for referece. |
>| event | `Emitter` | ✔ | An event emitter object. |
>
>Creates a new instance of Connection.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `connection` | The new Connection object. |
>
>**Table structure**:
>```Lua
>{
>	event = { }, -- The event emitter object, used to trigger events.
>	socket = { }, -- The socket object, used to create the connection between the bot and the game.
>	buffer = { }, -- The buffer object, used to control the packets flow when received by the socket.
>	ip = "", -- IP of the server where the socket is connected. Empty if it is not connected.
>	packetID = 0, -- An identifier ID to send the packets in the correct format.
>	port = 1, -- The index of one of the ports from the enumeration 'ports'. It gets constant once a port is accepted in the server.
>	name = "", -- The name of the connection object, for reference.
>	open = false -- Whether the connection is open or not.
>}
>```
>
---
>### connection:close (  )
>Ends the socket connection.
>
---
>### connection:connect ( ip, port )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| ip | `string` | ✔ | The server IP. |
>| port | `int` | ✕ | The server port. If nil, all the available ports are going to be used until one gets connected. |
>
>Creates a socket to connect to the server of the game.
>
---
>### connection:receive (  )
>
>Retrieves the data received from the server.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The bytes that were removed from the buffer queue. Can be nil if the queue is empty. |
>
---
>### connection:send ( identifiers, alphaPacket )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| identifiers | `table` | ✔ | The packet identifiers in the format (C, CC). |
>| alphaPacket | `byteArray`, `string`, `number` | ✔ | The packet ByteArray, ByteString or byte to be sent to the server. |
>
>Sends a packet to the server.
>