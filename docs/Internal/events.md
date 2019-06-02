# Private Events
Private events should never be overwrited or the API will not work as it should.

---
>### \_receive ( connection, packet )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| connection | `connection` | The connection where the packet came from. |
>| port | `bArray` | The packet received. |
>
>Triggered when the socket receives a packet. (Initial stage, before [receive](../Events.md#receive--connection-identifiers-packet-))
>
---
>### \_socketConnection ( connection, port )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| connection | `connection` | The connection. |
>| port | `int` | The port where the socket got connected. |
>
>Triggered when the socket gets connected.
>