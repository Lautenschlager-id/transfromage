# Guide

## Installing Transfromage

### Luvit

Using a command prompt or terminal, create a new directory where you would like to install Luvit executables.

Follow the installation instructions at https://luvit.io/install.html according to your operational system.<br>
###### If you get installation issues, get the executables using this: [Get-Lit](https://github.com/SinisterRectus/get-lit).

The files `lit`, `luvit`, and `luvit` are needed. Make sure that you have them in your new directory once its installed, otherwise the API will not work.

### Transfromage

With the three executables installed, run `lit install Lautenschlager-id/transfromage` to get a `deps` folder with the Transfromage API.

# Documentation

Note that no methods will handle invalid parameters (except for enumerations) or "client-side" errors.

## Topics

- [Client](Client.md)
- [Enum](Enum.md)
- [Events](Events.md)

## Tree

- [Client](Client.md)
	- [changeWhisperState](Client.md#clientchangewhisperstate--message-state-)
	- [chatWho](Client.md#clientchatwho--chatname-)
	- [closeChat](Client.md#clientclosechat--chatname-)
	- [connect](Client.md#clientconnect--username-userpassword-startroom-timeout-)
	- [connectionTime](Client.md#clientconnectiontime---)
	- [createCafeTopic](Client.md#clientcreatecafetopic--title-message-)
	- [emit](Client.md#clientemit--eventname--)
	- [enterRoom](Client.md#cliententerroom--roomname-issalonauto-)
	- [insertOldPacketListener](Client.md#clientinsertoldpacketlistener--C-CC-f-)
	- [insertPacketListener](Client.md#clientinsertpacketlistener--C-CC-f-)
	- [insertTribulleListener](Client.md#clientinserttribullelistener--tribulleid-f-)
	- [joinChat](Client.md#clientjoinchat--chatname-)
	- [joinTribeHouse](Client.md#clientjointribehouse--)
	- [kickTribeMember](Client.md#clientkicktribemember--membername-)
	- [likeCafeMessage](Client.md#clientlikecafemessage--topicid-messageid-deslike-)
	- [loadLua](Client.md#clientloadlua--script-)
	- [on](Client.md#clienton--eventname-callback-)
	- [once](Client.md#clientonce--eventname-callback-)
	- [openCafe](Client.md#clientopencafe--close-)
	- [openCafeTopic](Client.md#clientopencafetopic--topicid-)
	- [playEmote](Client.md#clientplayemote--emote-flag-)
	- [playEmoticon](Client.md#clientplayemoticon--emoticon-)
	- [recruitPlayer](Client.md#clientrecruitplayer--playername-)
	- [requestRoomList](Client.md#clientrequestroomlist--roommode-)
	- [sendCafeMessage](Client.md#clientsendcafemessage--topicid-message-)
	- [sendChatMessage](Client.md#clientsendchatmessage--chatname-message-)
	- [sendCommand](Client.md#clientsendcommand--command-)
	- [sendRoomMessage](Client.md#clientsendroommessage--message-)
	- [sendTribeMessage](Client.md#clientsendtribemessage--message-)
	- [sendWhisper](Client.md#clientsendwhisper--targetuser-message-)
	- [setCommunity](Client.md#clientsetcommunity--community-)
	- [setTribeMemberRole](Client.md#clientsettribememberrole--membername-roleid-)
	- [start](Client.md#clientstart--tfmid-token-)
- [Enum](Enum.md)
	- [chatCommunity](Enum.md#chatcommunity-int)
	- [community](Enum.md#community-int)
	- [emote](Enum.md#emote-int)
	- [emoticon](Enum.md#emoticon-int)
	- [gender](Enum.md#gender-int)
	- [identifier](Enum.md#identifier-table)
	- [role](Enum.md#role-int)
	- [roomMode](Enum.md#roommode-int)
	- [setting](Enum.md#setting-table)
	- [whisperState](Enum.md#whisperstate-int)
- [Events](Events.md)
	- [cafeTopicList](Events.md#cafetopiclist--data-)
	- [cafeTopicLoad](Events.md#cafetopicload--topic-)
	- [cafeTopicMessage](Events.md#cafetopicmessage--message-topic-)
	- [chatMessage](Events.md#chatmessage--channelname-playername-message-playercommunity-)
	- [chatWho](Events.md#chatwho--chatname-data-)
	- [connection](Events.md#connection---)
	- [disconnection](Events.md#disconnection--connection-)
	- [heartbeat](Events.md#heartbeat--time-)
	- [friendConnection](Events.md#friendconnection--playername-)
	- [friendDisconnection](Events.md#frienddisconnection--playername-)
	- [joinTribeHouse](Events.md#jointribehouse--tribename-)
	- [lua](Events.md#lua--log-)
	- [missedOldPacket](Events.md#missedoldpacket--connection-identifiers-packet-)
	- [missedPacket](Events.md#missedpacket--connection-identifiers-packet-)
	- [missedTribulle](Events.md#missedtribulle--connection-tribulleid-packet-)
	- [newGame](Events.md#newgame--map-)
	- [newTribeMember](Events.md#newtribemember--membername-)
	- [ping](Events.md#ping---)
	- [profileLoaded](Events.md#profileloaded--data-)
	- [ready](Events.md#ready---)
	- [receive](Events.md#receive--connection-packet-identifiers-)
	- [roomChanged](Events.md#roomchanged--roomname-isprivateroom-)
	- [roomList](Events.md#roomlist--roommode-rooms-pinned-)
	- [roomMessage](Events.md#roommessage--playername-message-playercommunity-playerid-)
	- [send](Events.md#send--identifiers-packet-)
	- [staffList](Events.md#stafflist--list-)
	- [tribeMemberConnection](Events.md#tribememberconnection--membername-)
	- [tribeMemberDisconnection](Events.md#tribememberdisconnection--membername-)
	- [tribeMemberGetRole](Events.md#tribemembergetrole--membername-settername-role-)
	- [tribeMemberKick](Events.md#tribememberkick--membername-kickername-)
	- [tribeMemberLeave](Events.md#tribememberleave--membername-)
	- [tribeMessage](Events.md#tribemessage--membername-message-)
	- [time](Events.md#time--time-)
	- [whisperMessage](Events.md#whispermessage--playername-message-playercommunity-)