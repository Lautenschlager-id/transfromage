[![Donate](https://img.shields.io/badge/Donate-PayPal-blue.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=TSTEG3PXK4HJ4&source=url)

<p align='center'><a href='https://atelier801.com/topic?f=5&t=917024'><img src="http://images.atelier801.com/168e7d7a07d.png" title="Transfromage"></a></p>

**Transformice's API written in Lua (5.1▲) using the Luvit runtime environment**

## About

[Transformice](https://www.transformice.com/) is an online independent multiplayer free-to-play platform video game created by the French company [Atelier801](http://societe.atelier801.com/).

[Luvit](https://luvit.io/) is an open-source, asynchronous I/O Lua runtime environment that makes requests and connections possible for the Lua programming language.

**Transfromage API** is a [documented API](docs) that allows developers to make bots for the aforementioned game.

Join the **_[Fifty Shades of Lua](https://discord.gg/qmdryEB)_** [discord](https://discordapp.com/) server to discuss about this API and to receive special support.

You can also check out **[Fromage API](https://github.com/Lautenschlager-id/Fromage)** for Atelier801's forum.

This API had many indirect contributors, including [@Tocutoeltuco](https://github.com/Tocutoeltuco), [@Useems](https://github.com/Useems), [@Turkitutu](https://github.com/Turkitutu), [@Athesdrake](https://github.com/Athesdrake) and the [python version of Transfromage API](https://github.com/Tocutoeltuco/transfromage).

![/!\\](https://i.imgur.com/HQ188PK.png) **v8.1.0 has undocumented changes and is a quick patch to keep the API working. A new, better, version of the API is under development and will be released soon.**

## Authentication keys Endpoint

This API relies on an [endpoint](https://api.tocuto.tk/get_transformice_keys.php) that gives you access to the Transformice encryption keys.

To use it you will need a token which you can get by [applying through this form](https://forms.gle/N6Et1hLGQ9hmg95F6). See below to know the names of Transfromage managers who handle the token system.
- **[Tocutoeltuco](https://github.com/Tocutoeltuco)** @discord=> `Tocutoeltuco#0018` <sub>`212634414021214209`</sub>;
- **[Blank3495](https://github.com/Blank3495)** @discord=> `󠂪󠂪 󠂪󠂪 󠂪󠂪󠂪󠂪 󠂪󠂪 󠂪󠂪󠂪󠂪 󠂪󠂪 󠂪󠂪#8737` <sub>`436703225140346881`</sub>;
- **[Bolodefchoco](https://github.com/Lautenschlager-id)** @discord=> `Lautenschlager#2555` <sub>`285878295759814656`</sub>.

## Installation

- To install Luvit, visit https://luvit.io and follow the instructions provided for your platform.
	- If you face problems installing it on Windows, please use [Get-Lit](https://github.com/SinisterRectus/get-lit)
- To install **Transfromage**, run `lit install Lautenschlager-id/transfromage`
- Run your bot script using luvit, for example: `luvit bot.lua`

###### If you are new and can't follow these steps, please consider using _MyFirstBot.zip_ that has been premade with the executables and the API.<br>_(4MB)_ [Windows](https://github.com/Lautenschlager-id/Transfromage/raw/master/MyFirstBot/Windows.zip) | [Linux](https://github.com/Lautenschlager-id/Transfromage/raw/master/MyFirstBot/Linux.zip)

### API Update

To update the API automatically all you need to do is to create a file named `autoupdate` in the bot's path.<br>
You can create it running `cd. > autoupdate` (for Windows) or `touch autoupdate` (for Linux);

The update will overwrite all the old files and dependencies.

For semi-automatic updates (which asks for your permission before updating), create the file `semiautoupdate` instead.

### Contributing

The best way to contribute to this API is by ~~donating~~ creating pull requests with bug fixes and new events / methods (like joining the map editor, getting a map XML, loading Lua...)

Read [CONTRIBUTING](CONTRIBUTING.md) to learn about how you can contribute to the API.<br>
See [CONTRIBUTORS](CONTRIBUTORS.md).

## Base example
###### You can check more examples [here](https://github.com/Lautenschlager-id/Transfromage/tree/master/examples).
```Lua
local api = require("transfromage")
local client = api.client()

client:once("ready", function()
	client:connect("Username#0000", "password")
end)

client:start("PLAYER_ID", "API_TOKEN")
```

###### Suggestion for reconnection on login failure
```Lua
client:on("ready", function()
	client:connect("Username#0000", "password")
end)

client:on("connectionFailed", function()
	client:start("PLAYER_ID", "API_TOKEN")
end)

client:emit("connectionFailed")
```