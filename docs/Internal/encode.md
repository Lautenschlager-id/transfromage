# Encode
Represents encoding functions.

---
# Static Functions
>### encode.getPasswordHash ( password )
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

# Functions
>### encode:btea ( packet )
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
>### encode:xorCipher ( packet, fingerprint )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| packet | `byteArray` | ✔ | A Byte Array object to be encoded. |
>| fingerprint | `int` | ✔ | The fingerprint of the encode. |
>
>Encodes a packet using the XOR cipher.<br>
>If hasSpecialRole is true, then the raw packet is returned.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `byteArray` | The encoded Byte Array object. |
>

# Private Functions
>### xxtea ( self, data )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| self | `encode` | ✔ | An Encode object. |
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