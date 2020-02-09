# ByteArray
Byte arrays are used to control packets and are a lua recreation of the ByteStrings.

---
>### byteArray:new ( stack )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| stack | `table` | ✕ | An array of bytes. |
>
>Creates a new instance of a Byte Array. Alias: `byteArray()`.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `byteArray` | The new Byte Array object. |
>
>**Table structure**:
>```Lua
>{
>	stack = { } -- The bytes stack
>}
>```
>
---
>### byteArray:read8 ( quantity )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| quantity | `int` | ✔ | The quantity of bytes to be extracted. <sub>(default = 1)</sub> |
>
>Extracts bytes from the packet stack. If there are not suficient bytes in the stack, it's filled with bytes with value 0.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `int` | A table with the extracted bytes. If there's only one byte, it is sent instead of the table. |
>
---
>### byteArray:read16 (  )
>
>Extracts a short integer from the packet stack.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `int` | A short integer. |
>
---
>### byteArray:readSigned16 (  )
>
>Extracts a short signed integer from the packet stack.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `int` | A short signed integer. |
>
---
>### byteArray:read24 (  )
>
>Extracts an integer from the packet stack.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `int` | An integer. |
>
---
>### byteArray:read32 (  )
>
>Extracts a long integer from the packet stack.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `int` | A long integer. |
>
---
>### byteArray:readBigUTF (  )
>
>Extracts a long string from the packet stack.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string` | A long string. |
>
---
>### byteArray:readBool (  )
>
>Extracts a boolean from the packet stack. (Whether the next byte is 0 or 1)
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `boolean` | A boolean. |
>
---
>### byteArray:readUTF (  )
>
>Extracts a string from the packet stack.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string` | A string. |
>
---
>### byteArray:write8 ( ... )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| ... | `int` | ✕ | Bytes. <sub>(default = 0)</sub> |
>
>Inserts bytes in the byte array.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `byteArray` | Object instance. |
>
---
>### byteArray:write16 ( short )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| short | `int` | ✔ | An integer number in the range [0, 65535]. |
>
>Inserts a short integer in the byte array.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `byteArray` | Object instance. |
>
---
>### byteArray:write24 ( int )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| int | `int` | ✔ | An integer number in the range [0, 16777215]. |
>
>Inserts an integer in the byte array.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `byteArray` | Object instance. |
>
---
>### byteArray:write32 ( long )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| long | `int` | ✔ | An integer number in the range [0, 4294967295]. |
>
>Inserts a long integer in the byte array.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `byteArray` | Object instance. |
>
---
>### byteArray:writeBigUTF ( bigUtf )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| utf | `table`, `string` | ✔ | A string/table with a maximum of 16777215 characters/values. |
>
>Inserts a string in the byte array.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `byteArray` | Object instance. |
>
---
>### byteArray:writeBool ( bool )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| bool | `boolean` | ✔ | A boolean. |
>
>Inserts a byte (0, 1) in the byte array.
>
---
>### byteArray:writeUTF ( utf )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| utf | `table`, `string` | ✔ | A string/table with a maximum of 65535 characters/values. |
>
>Inserts a string in the byte array.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `byteArray` | Object instance. |
>