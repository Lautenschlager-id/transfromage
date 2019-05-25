# Functions
>### download ( language )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| language | `enum.language` | ✔ | An enum from [language](Enum.md#language-string). (index or value) <sub>(default = en)</sub> |
>
>Downloads a Transformice language file.
>
---
>### free ( language, whitelist, whitelistPattern )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| language | `enum.language` | ✔ | An enum from [language](Enum.md#language-string) that was downloaded before with [download](#download--language-). |
>| whitelist | `table` | ✕ | A set ([index]=true) of indexes that must not be deleted. |
>| whitelistPattern | `string` | ✕ | A pattern to match various indexes at once, these indexes won't be deleted. |
>
>Deletes translation lines that are not going to be used. (Save process)<br>
>If the whitelist parameters are not set, it will delete the whole translation data.
>
---
>### get ( language, index, raw )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| language | `enum.language` | ✔ | An enum from [language](Enum.md#language-string) that was downloaded before with [download](#download--language-). |
>| index | `string` | ✕ | The code of the translation line. |
>| raw | `boolean` | ✕ | Whether the translation line must be sent in raw mode or filtered. <sub>(default = false)</sub> |
>
>Gets a translation line.
>
>**Returns:**
>
>| Type | Description |
>| :-: | - |
>| `string`, `table` | The translation line. If @index is nil, then it's the translation table (index = value). If @index exists, it may be the string, or @raw string, or a table if it has gender differences ({ male, female }). It may not exist. |
>| `boolean`, `nil` | If not @raw, the value is a boolean true if return #1 is table. |
