# Contribute to the API

## Donations
[![Donate](https://img.shields.io/badge/Donate-PayPal-blue.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=TSTEG3PXK4HJ4&source=url)

Funny or not, donations are fundamental to keep the development of the project.

If you have disponibility to donate any value, do not hesitate in helping us on PayPal!

###### Thanks for all the **$22** of donations until now! ♥

## Documentation

You must document every function / event in your pull request, but it's not necessary to edit the markdown files.

To document [Methods](docs/Client.md) use the format provided [here](https://github.com/Lautenschlager-id/Fromage/blob/master/docgen.lua#L1-L36).<br>
Currently the [Events documentation](docs/Events.md) has to be done manually using the functions format.

## Coding Convention
The code style does matter in your pull requests.<br>
Please, follow the clear convention used in the files or you risk not to get your pull request accepted.

\- Use tab to indent the code:
```Lua
	local x = 0 -- Correct
    local x = 0 -- Wrong
```
\- Ifs not only returning nil must be written in different lines:
```Lua
-- Correct
if true then return end
if true then
	x() -- Correct
end
-- Wrong
if true then
	return
end
if true then x() end
```
\- Comments are only needed when a detailed explaination sums up to the understanding of the line;<br>
\- Function must not use sugar syntax. (also applies for OOP):
```Lua
-- Correct
x = function(a, b)
o.x = function(self, ...)
-- Wrong
function x(a, b)
function o:x(...)
```
\- Global functions must be avoided;<br>
\- There must not be indexes and values spaced as in enumerators:
```Lua
-- Correct
local hi = 0
local name = 1
-- Wrong
local hi   = 0
local name = 1
```
\- Functions must not be called without parentheses;<br>
\- Tables must start and end with a space:
```Lua
local id = { 1, 2, 3 } -- Correct
local id = {1, 2, 3} -- Wrong
```
\- Use one space between operators:
```Lua
local x = 1 + 1 -- Correct
local x = 1+1 -- Wrong
```
\- Avoid unnecessary parentheses in conditions or flow controls;<br>
\- Use an underscore, `_`, in variables and indexes that are (or should be) only used internally in the API.

## Packet parsers
The packet parsers in the file [Client.lua](libs/client.lua) handle the `C` and `CC` individually in hashed tables, making the system ellegant and efficient.

Use their specific tables to add new events as necessary. Pull requests with the _insertXListener_ are not going to be accepted.

If you are editing an existent event, please make the reasons clear in your pull request commentary.

### Tribulle events
Tribulle is everything related to the community platform.
- Search for `-- Tribulle functions` or for the table `tribulleListener`;
- Each function receives the parameters:
	- `self`<sub>\<[client](docs/Client.md)></sub> The instance receiving the data;
	- `packet`<sub>\<[byteArray](docs/Internal/bArray.md)></sub> The data received;
	- `connection`<sub>\<[connection](docs/Internal/connection.md)></sub> The connection that received the data;
	- `tribulleId`<sub>\<int></sub> The tribulle id (just for reference)

### Regular events
- Search for `-- Normal functions` or for the table `packetListener`;
- Each function receives the parameters:
	- `self`<sub>\<[client](docs/Client.md)></sub> The instance receiving the data;
	- `packet`<sub>\<[byteArray](docs/Internal/bArray.md)></sub> The data received;
	- `connection`<sub>\<[connection](docs/Internal/connection.md)></sub> The connection that received the data.
	- `identifiers`<sub>\<table></sub> The identifiers (C, CC) received. (just for reference)

### Old-Packet events
Old packets were used in the old version of the system. They are the data extracted from the first UTF of the received packet.
- Search for `-- Old packet functions` or for the table `oldPacketListener`;
- Each function receives the parameters:
	- `self`<sub>\<[client](docs/Client.md)></sub> The instance receiving the data;
	- `packet`<sub>\<[byteArray](docs/Internal/bArray.md)></sub> The data extracted;
	- `connection`<sub>\<[connection](docs/Internal/connection.md)></sub> The connection that received the data.
	- `oldIdentifiers`<sub>\<table></sub> The identifiers (oldC, oldCC) received. (just for reference)

## Functions
Functions and methods are used by the instanced object to perform actions in the game.

If you are editing an existent function, please make the reasons clear in your pull request commentary.

It is not necessary that you handle parameter type errors, expect if the parameter needs an enumeration.<br>
If the parameter requires an enumeration, use the function (enum._validate)[docs/Internal/enum.md#enumvalidate--enumeration-default-value-errormsg-]

## Enumerations
Enumerations should only be created if necessary. They indicate imutable values of an action or behavior.

They must be created in the file [Enum.lua](libs/enum.lua) and must follow:

\- Must use the function (constructor) `enum` to create enumerators;<br>
→ Must set the second value as `true` if there are identical values in the table.<br>
\- Must space all its values in the same position:
```Lua
{
	apple     = 1,
	pineapple = 2,
	sandwich  = 3
}
```
\- Enumerators must be aligned, and if the values are numbers, they must be appended to zeroes based on the highest value:
```Lua
{
	apple     = 001,
	pineapple = 002,
	sandwich  = 003,
	soda      = 100
}
```

#Files
New files must start with requires, constructors and auxiliar functions, and the main functions at the end.

Your file must not overwrite functions or tables that are in other files.