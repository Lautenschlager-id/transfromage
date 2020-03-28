# Bitwise
Represents 64bits-integer bitwise functions.

---
>### bitwise.band ( x, y )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| x | `int` | ✔ | The first integer. |
>| y | `int` | ✔ | The second integer. |
>
>Returns the bitwise _& (and)_ between two integers.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `int` | The result of the & operation. |
>
---
>### bitwise.bxor ( x, y )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| x | `int` | ✔ | The first integer. |
>| y | `int` | ✔ | The second integer. |
>
>Returns the bitwise _^ (xor)_ between two integers.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `int` | The result of the ^ operation. |
>
---
>### bitwise.lshift ( x, disp )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| x | `int` | ✔ | An integer. |
>| disp | `int` | ✔ | Quantity of bits to be left-shifted in @x. |
>
>Shifts an integer number to the left.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `int` | The integer @x shifted @disp bits to the left. |
>
---
>### bitwise.rshift ( x, disp )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| x | `int` | ✔ | An integer. |
>| disp | `int` | ✔ | Quantity of bits to be right-shifted in @x. |
>
>Shifts an integer number to the right.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `int` | The integer @x shifted @disp bits to the right. |
>