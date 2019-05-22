# Functions
Enumerations and enumerators are constant and imutable values used in the API.

---
>### enum.\_exists ( enumeration, value )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| enumeration | `enum` | ✔ | An enumeration object, the source of the value. |
>| value | `*` | ✔ | The value (index or value) of the enumeration. |
>
>Checks whether the inserted enumeration is valid or not.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `int`, `boolean` | Whether @value is part of @enumeration or not. It's returned 0 if the value is a value, 1 if it is an index, and false if it's not a valid enumeration. |
>
---
>### enum.\_validate ( enumeration, default, value, errorMsg )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| enumeration | `enum` | ✔ | An enumeration object, the source of the value. |
>| default | `*` | ✔ | The default value of the enumeration |
>| value | `string`, `number` | ✕ | The value (index or value) of the enumeration. |
>| errorMsg | `string` | ✕ | The error message when the enumeration exists but is invalid. |
>
>Validates an enumeration.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `*` | The value associated to the source enumeration, or the default value if nil. |
>