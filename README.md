[![Donate](https://img.shields.io/badge/Donate-PayPal-blue.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=TSTEG3PXK4HJ4&source=url)

<p align='center'><a href='https://atelier801.com/topic?f=5&t=917024'><img src="http://images.atelier801.com/168e7d7a07d.png" title="Transfromage"></a></p>

**Transformice's API written in Lua (5.1▲) using the Luvit runtime environment**

## About

[Transformice](https://www.transformice.com/) is an online independent multiplayer free-to-play platform video game created by the french company [Atelier801](http://societe.atelier801.com/).

[Luvit](https://luvit.io/) is an open-source, asynchronous I/O Lua runtime environment that makes requests and connections possible for the Lua programming language.

**Transfromage API** is a [documented API](docs) that allows developers to make bots for the mentioned game.

Join the **_[Fifty Shades of Lua](https://discord.gg/quch83R)_** [discord](https://discordapp.com/) to discuss about this API and to have special support.

See also the **[Fromage API](https://github.com/Lautenschlager-id/Fromage)** for the Atelier801's forum.

This API had many indirect contributors, including [@Tocutoeltuco](https://github.com/Tocutoeltuco), [@Useems](https://github.com/Useems), [@Turkitutu](https://github.com/Turkitutu), [@Athesdrake](https://github.com/Athesdrake) and the [python Transfromage API](https://github.com/Tocutoeltuco/transfromage).

## Keys Endpoint

This API depends on an [endpoint](https://api.tocu.tk/get_transformice_keys.php) that gives you access to the Transformice encryption keys.

To get access to it you need to request a token, after explaining your project, to one of the following players:
- **[Tocutoeltuco](https://github.com/Tocutoeltuco)** @discord=> `Tocutoeltuco#0018`;
- **Blank#3495** @discord=> `󠂪󠂪 󠂪󠂪 󠂪󠂪󠂪󠂪 󠂪󠂪 󠂪󠂪󠂪󠂪 󠂪󠂪 󠂪󠂪#8737`;
- **[Bolodefchoco](https://github.com/Lautenschlager-id)** @discord=> `Lautenschlager#2555`.

## Installation

- To install Luvit, visit https://luvit.io and follow the instructions provided for your platform.
	- If you have problems installing it on Windows, please use [Get-Lit](https://github.com/SinisterRectus/get-lit)
- To install **Transfromage**, run `lit install Lautenschlager-id/transfromage`
- Run your bot script using, for example, `luvit bot.lua`

###### If you are new and can't follow these steps, please consider using the _MyFirstBot.zip_ that comes with the executables and API already.<br>_(4MB)_ [Windows](https://github.com/Lautenschlager-id/Transfromage/raw/master/MyFirstBot/Windows.zip) | [Linux](https://github.com/Lautenschlager-id/Transfromage/raw/master/MyFirstBot/Linux.zip)

### API Update

To update the API automatically all you need to do is to create a file named `autoupdate` in the bot's path.<br>
You can create it running `cd. > autoupdate` (for Windows) or `touch autoupdate` (for Linux);

The update will overwrite all the old files and dependencies.

For semi-automatic updates (asks permission before updating), create the file `semiautoupdate` instead.

### Contributing

The best way to contribute for this API is ~~donating~~ creating pull requests with bug fixes and new events / methods (like joining the map editor, getting a map XML, loading Lua...)

Read [CONTRIBUTING](CONTRIBUTING.md) to learn more about contributions for the API.

## Base example

```Lua
local api = require("transfromage")
local client = api.client:new()

client:once("ready", function()
	client:connect("Username#0000", "password")
end)

client:start("Owner ID", "API Token")
```