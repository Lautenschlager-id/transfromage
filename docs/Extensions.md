# Helper Functions
>### coroutine.makef ( f )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| f | `function` | ✔ | Function to be executed inside a coroutine. |
>
>Creates a coroutine to execute the given function.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `function` | A coroutine with @f to be executed. |
>
---
>### math.normalizePoint ( n )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| n | `number` | ✔ | The coordinate point value. |
>
>Normalizes a Transformice coordinate point value.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `int` | The normalized coordinate point value. |
>
---
>### os.log ( str, returnValue )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| str | `string` | ✔ | The message to be sent. It may included color formats. |
>| returnValue | `boolean` | ✕ | Whether the formated message has to be returned. If not, it'll be sent to the prompt automatically. <sub>(default = false)</sub> |
>
>Sends a log message with colors to the prompt of command.<br>
>Color format is given as `↑name↓text↑`, as in `↑error↓[FAIL]↑`.<br>
>Available code names: `error`, `failure`, `highlight`, `info`, `success`.<br>
>This function is also available for the `error` function. Ex: `error("↑error↓Bug↑")`
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `nil`,`string` | The formated message, depending on @returnValue. |
>
---
>### string.fixEntity ( str )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| str | `string` | ✔ | The string. |
>
>Normalizes a string that has HTML entities.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string` | The normalized string. |
>
---
>### string.getBytes ( str )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| str | `string` | ✔ | The string. |
>
>Gets the bytes of the characters of a string.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table` | An array of bytes. |
>
---
>### string.split ( str, separator, raw )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| str | `string` | ✔ | The string to be split. |
>| separator | `string` | ✔ | The string that the function is going to use as separator. |
>| raw | `boolean` | ✕ | Whether @separator is a string or a pattern. <sub>(default = false)</sub> |
>
>Splits a string into parts based on a pattern.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table` | The data of the split string. |
>
---
>### string.toNickname ( str, checkDiscriminator )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| str | `string` | ✔ | The nickname to be normalized. May not included the #tag. |
>| checkDiscriminator | `boolean` | ✕ | If it must append '#0000' if no #tag is detected. <sub>(default = false)</sub> |
>
>Normalizes an inserted nickname.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string` | The normalized nickname. |
>
---
>### string.utf8 ( str )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| str | `string` | ✔ | The string. |
>
>Transforms a Lua string into a UTF8 string.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table` | A table split by UTF8 char. |
>
---
>### table.add ( src, add )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| str | `table` | ✔ | The source table, the one receiving the new values. |
>| add | `table` | ✔ | The table where the new values are coming from. |
>
>Links two arrays by reference.
>
---
>### table.arrayRange ( arr, i, j )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| arr | `table` | ✔ | The array. |
>| i | `int` | ✕ | The initial index of the range. <sub>(default = 1)</sub> |
>| j | `int` | ✕ | The final index of the range. <sub>(default = #@arr)</sub> |
>
>Gets the values of an array within a given range.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table` | A new array with the values obtained from @arr within the range [@i, @j]. |
>
---
>### table.fuse ( arrA, arrB )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| arrA | `table` | ✔ | The source table, the one receiving the new values. |
>| arrB | `table` | ✔ | The table where the new values are coming from. |
>
>Links two given arrays.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table` | The new table with the values of both @arrA and @arrB. |
>
---
>### table.copy ( list )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| list | `table` | ✔ | The table to be copied. |
>
>Copies a table to remove its reference.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table` | A new table with all values and indexes of @list. |
>
---
>### table.join ( arr, value )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| arr | `table` | ✔ | The array to be split. |
>| value | `*` | ✔ | The value to be added between the values of @arr. |
>
>Splits an array, adding a value between each value.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table` | The split array. |
>
---
>### table.setNewClass (  )
>
>Creates a new class constructor.<br>
>If the table receives a new index with a string value, it'll create an alias.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table` | A metatable with constructor and alias handlers. |
>
---
>### table.writeBytes ( bytes )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| bytes | `table` | ✔ | The array of bytes. |
>
>Converts an array of bytes into a string. (Not a bytestring)
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string` | A string from the array of bytes. |
>