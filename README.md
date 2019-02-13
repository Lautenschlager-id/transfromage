[![Donate](https://img.shields.io/badge/Donate-PayPal-yellow.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=TSTEG3PXK4HJ4&source=url)

<p align='center'><a href='https://atelier801.com/topic?f=5&t=917024'><img src="http://images.atelier801.com/168e7d7a07d.png" title="Fromage"></a></p>

**Transformice's API written in Lua (5.1▲) using the Luvit runtime environment**

## About

[Transformice](https://www.transformice.com/) is an online independent multiplayer free-to-play platform video game created by the french company [Atelier801](http://societe.atelier801.com/).

[Luvit](https://luvit.io/) is an open-source, asynchronous I/O Lua runtime environment that makes requests and connections possible for the Lua programming language.

**TransFromage API** is a [documented API](docs) that allows developers to make bots for the mentioned game.

Join the **_[Fifty Shades of Lua](https://discord.gg/quch83R)_** [discord](https://discordapp.com/) to discuss about this API and to have special support.

See also the [**Fromage API**](https://github.com/Lautenschlager-id/Fromage) for the Atelier801's forum.

## Installation

- To install Luvit, visit https://luvit.io and follow the instructions provided for your platform.
	- If you have problems installing it on Windows, please use [Get-Lit](https://github.com/SinisterRectus/get-lit)
- To install **TransFromage**, run `lit install Lautenschlager-id/transfromage`
- Run your bot script using, for example, `luvit bot.lua`

###### If you are new and can't follow these steps, please consider using the _MyFirstBot.zip_ that comes with the executables and API already.<br>_(4MB)_ [Windows](MyFirstBot/Windows.zip) | [Linux](MyFirstBot/Linux.zip)

### API Update

To update the API automatically all you need to do is to create a file named `autoupdate` in the bot's path.<br>
You can create it running `echo >> autoupdate` (for Windows) or `touch autoupdate` (for Linux);

The update will overwrite all the old files and dependencies.

### Contribution

The best way to contribute for this API is ~~donating~~ creating pull requests with bug fixes and new events / methods (like joining the map editor, getting a map XML, loading Lua...)

You may find the Tribulle part [here](libs/client.lua) by searching `-- Tribulle functions` - the format is `[C][CC](connection, packet, C_CC)` -. You may also find the methods part in the same file by searching `-- Methods`.

Currently the [Events documentation](docs/Events.md) has to be done manually. To document [Methods](docs/Client.md) use the format provided [here](https://github.com/Lautenschlager-id/Fromage/blob/master/docgen.lua#L1-L36).

## Base example

```Lua
local api = require("transfromage")
local client = api.client:new()

client:once("ready", function()
	client:connect("Username#0000", "password")
end)

client:start("Owner ID", "API Token")
```