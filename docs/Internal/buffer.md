# Buffer
Buffers control the packets queue from inside.

---
>### buffer:new (  )
>
>Creates a new instance of Buffer. Alias: `buffer()`.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `buffer` | The new Buffer object. |
>
>**Table structure**:
>```Lua
>{
>	queue = { }, -- The bytes queue
>	_count = 0 -- The number of bytes in the queue
>}
>```
>
---
>### buffer:push ( bytes )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| bytes | `table`, `string` | ✔ | A string/table of bytes. |
>
>Inserts bytes to the queue.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `buffer` | Object instance. |
>
---
>### buffer:receive ( length )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| length | `int` | ✔ | The quantity of bytes to be extracted. |
>
>Retrieves bytes from the queue.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table` | An array of bytes.  |
>