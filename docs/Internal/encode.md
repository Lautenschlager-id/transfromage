# Functions
Functions to encode data.

---
>### btea ( packet )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| packet | `byteArray` | ✔ | A Byte Array object to be encoded. |
>
>Encodes a packet with the BTEA block cipher.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `byteArray` | The encoded Byte Array object. |
>
---
>### getPasswordHash ( password )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| password | `string` | ✔ | The account's password. |
>
>Encrypts the account's password.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string` | The encrypted password. |
>
---
>### setPacketKeys ( idKeys, msgKeys )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| idKeys | `table` | ✔ | The identification keys of the SWF/endpoint. |
>| msgKeys | `table` | ✔ | The message keys of the SWF/endpoint. |
>
>Sets the packet keys.
>
---
>### xorCipher ( packet, fingerprint )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| packet | `byteArray` | ✔ | A Byte Array object to be encoded. |
>| fingerprint | `int` | ✔ | The fingerprint of the encode. |
>
>Encodes a packet using the XOR cipher.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `byteArray` | The encoded Byte Array object. |
>

# Private Functions
>### xxtea ( data )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| data | `table` | ✔ | A table with data to be encoded. |
>
>XXTEA partial 64bits encoder.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table` | The encoded data. |
>