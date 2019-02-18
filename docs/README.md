# Guide

## Installing TransFromage

### Luvit

Using a command prompt or terminal, create a new directory where you would like to install Luvit executables.

Follow the installation instructions at https://luvit.io/install.html according to your operational system.<br>
###### If you get installation issues, get the executables using this: [Get-Lit](https://github.com/SinisterRectus/get-lit).

The files `lit`, `luvit`, and `luvit` are needed. Make sure that you have them in your new directory once its installed, otherwise the API will not work.

### TransFromage

With the three executables installed, run `lit install Lautenschlager-id/transfromage` to get a `deps` folder with the TransFromage API.

# Documentation

## Topics

- [Client](Client.md)
- [Enum](Enum.md)
- [Events](Events.md)

## Tree

- [Client](Client.md)
	- [client.changeWhisperState](Client.md#clientchangewhisperstate--self-message-state-)
	- [client.closeChat](Client.md#clientclosechat--self-chatname-)
	- [client.connect](Client.md#clientconnect--self-username-userpassword-startroom-)
	- [client.enterRoom](Client.md#cliententerroom--self-roomname-issalonauto-)
	- [client.joinChat](Client.md#clientjoinchat--self-chatname-)
	- [client.joinTribeHouse](Client.md#clientjointribehouse--self-)
	- [client.loadLua](Client.md#clientloadlua--self-script-)
	- [client.on](Client.md#clienton--self-eventname-callback-)
	- [client.once](Client.md#clientonce--self-eventname-callback-)
	- [client.playEmote](Client.md#clientplayemote--self-emote-flag-)
	- [client.playEmoticon](Client.md#clientplayemoticon--self-emoticon-)
	- [client.sendChatMessage](Client.md#clientsendchatmessage--self-chatname-message-)
	- [client.sendCommand](Client.md#clientsendcommand--self-command-)
	- [client.sendRoomMessage](Client.md#clientsendroommessage--self-message-)
	- [client.sendTribeMessage](Client.md#clientsendtribemessage--self-message-)
	- [client.sendWhisper](Client.md#clientsendwhisper--self-targetuser-message-)
	- [client.setCommunity](Client.md#clientsetcommunity--self-community-)
	- [client.start](Client.md#clientstart--self-tfmid-token-)
- [Enum](Enum.md)
	- [chatCommunity](Enum.md#chatcommunity-int)
	- [community](Enum.md#community-int)
	- [emote](Enum.md#emote-int)
	- [emoticon](Enum.md#emoticon-int)
	- [gender](Enum.md#gender-int)
	- [identifier](Enum.md#identifier-table)
	- [role](Enum.md#role-int)
	- [setting](Enum.md#setting-table)
	- [whisperState](Enum.md#whisperstate-int)
- [Events](Events.md)
	- [chatMessage](Events.md#chatmessage--channelname-playername-message-playercommunity-)
	- [connection](Events.md#connection---)
	- [disconnection](Events.md#disconnection--connection-)
	- [heartbeat](Events.md#heartbeat--time-)
	- [joinTribeHouse](Events.md#jointribehouse--tribename-)
	- [lua](Events.md#lua--log-)
	- [missedPacket](Events.md#missedpacket--identifiers-packet-)
	- [ping](Events.md#ping---)
	- [ready](Events.md#ready---)
	- [receive](Events.md#receive--connection-packet-identifiers-)
	- [roomChanged](Events.md#roomchanged--roomname-isprivateroom-)
	- [roomMessage](Events.md#roommessage--playername-message-playercommunity-playerid-)
	- [send](Events.md#send--identifiers-packet-)
	- [tribeMessage](Events.md#tribemessage--membername-message-)
	- [whisperMessage](Events.md#whispermessage--playername-message-playercommunity-)