# API Functions
>### client:new (  )
>
>Creates a new instance of Client. Alias: `client()`.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `client` | The new Client object. |
>
>**Table structure**:
>```Lua
>{
>	playerName = "", -- The nickname of the account that is attached to this instance, if there's any.
>	community = 0, -- The community enum where the object is set to perform the login. Default value is EN.
>	main = { }, -- The main connection object, handles the game server.
>	bulle = { }, -- The bulle connection object, handles the room server.
>	event = { }, -- The event emitter object, used to trigger events.
>	cafe = { }, -- The cached Café structure. (topics and messages)
>	playerList = { }, -- The room players data.
>	-- The fields below must not be edited, since they are used internally in the api.
>	_mainLoop = { }, -- (userdata) A timer that retrieves the packets received from the game server.
>	_bulleLoop = { }, -- (userdata) A timer that retrieves the packets received from the room server.
>	_receivedAuthkey = 0, -- Authorization key, used to connect the account.
>	_gameVersion = 0, -- The game version, used to connect the account.
>	_gameConnectionKey = "", -- The game connection key, used to connect the account.
>	_gameIdentificationKeys = { }, -- The game identification keys, used to connect the account.
>	_gameMsgKeys = { }, -- The game message keys, used to connect the account.
>	_connectionTime = 0, -- The timestamp of when the account logged in. It will be 0 if the account is not connected.
>	_isConnected = false, -- Whether the account is connected or not.
>	_hbTimer = { }, -- (userdata) A timer that sends heartbeats to the server.
>	_who_fingerprint = 0, -- A fingerprint to identify the chat where the command /who was used.
>	_who_list = { }, -- A list of chat names associated to their own fingerprints.
>	_process_xml = false, -- Whether the event "newGame" should decode the XML packet or not. (Set as false to save process)
>	_cafeCachedMessages = { }, -- A set of message IDs to cache the read messages at the Café.
>	_handle_players = false -- Whether the player-related events should be handled or not. (Set as false to save process)
>}
>```
---
>### client:addFriend ( playerName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| playerName | `string` | ✔ | The player name to be added. |
>
>Adds a player to the friend list.
>
---
>### client:blacklistPlayer ( playerName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| playerName | `string` | ✔ | The player name to be added. |
>
>Adds a player to the black list.
>
---
>### client:changeWhisperState ( message, state )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| message | `string` | ✕ | The /silence message. <sub>(default = '')</sub> |
>| state | `enum.whisperState` | ✕ | An enum from [whisperState](Enum.md#whisperstate-int). (index or value) <sub>(default = enabled)</sub> |
>
>Sets the account's whisper state.
>
---
>### client:closeAll (  )
>Forces the private function [closeAll](Internal/client.md#closeall-self--) to be called.
>
>**Returns:**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the Connection objects can be destroyed or not. |
---
>### client:chatWho ( chatName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| chatName | `string` | ✔ | The name of the chat. |
>
>Gets the names of players in a specific chat. (/who)
>
---
>### client:closeChat ( chatName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| chatName | `string` | ✔ | The name of the chat. |
>
>Leaves a #chat.
>
---
>### client:connect ( userName, userPassword, startRoom, timeout )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| userName | `string` | ✔ | The name of the account. It must contain the discriminator tag (#). |
>| userPassword | `string` | ✔ | The password of the account. |
>| startRoom | `string` | ✕ | The name of the initial room. <sub>(default = "\*#bolodefchoco")</sub> |
>| timeout | `int` | ✕ | The time in ms to throw a timeout error if the connection takes too long to succeed. <sub>(default = 20000)</sub> |
>
>Connects to an account in-game.<br>
>It will try to connect using all the available ports before throwing a timing out error.
>
---
>### client:connectionTime (  )
>Gets the total time since the account was connected.
>
>**Returns:**
>
>| Type | Description |
>| :-: | - |
>| `int` | The total time since the account was logged in. |
---
>### client:createCafeTopic ( title, message )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| title | `string` | ✔ | The title of the topic. |
>| message | `string` | ✔ | The content of the topic. |
>
>Creates a Café topic.<br>
>![/!\\](https://i.imgur.com/HQ188PK.png) The method does not handle the Café's cooldown system.
>
---
>### client:emit ( eventName, ... )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| eventName | `string` | ✔ | The name of the event. |
>| ... | `*` | ✕ | The parameters to be passed during the emitter call. |
>
>Emits an event.<br>
>See the available events in [Events](Events.md). You can also create your own events / emitters.
>
---
>### client:enterRoom ( roomName, isSalonAuto )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| roomName | `string` | ✔ | The name of the room. |
>| isSalonAuto | `boolean` | ✕ | Whether the change room must be /salonauto or not. <sub>(default = false)</sub> |
>
>Enters a room.
>
---
>### client:handlePlayers ( handle )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| handle | `boolean` | ✕ | Whether the bot should handle the player events. The default value is the inverse of the current value. The instance starts the field as 'false'. |
>
>Toggles the field _\_handle\_players_ of the instance.<br>
>If 'true', the following events are going to be handled: _playerGetCheese_, _playerVampire_, _playerWon_, _playerLeft_, _playerDied_, _newPlayer_, _refreshPlayerList_, _updatePlayer_, _playerAction_.
>
>**Returns:**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the bot will handle the player events. |
---
>### client:getTranslation ( language, index, raw )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| language | `enum.language` | ✕ | An enum from [language](Enums.md#language-int). (index or value) <sub>(default = en)</sub> |
>| index | `string` | ✕ | The code of the translation line. |
>| raw | `boolean` | ✕ | Whether the translation line must be sent in raw mode or filtered. <sub>(default = false)</sub> |
>
>Gets a translation line in one of the Transformice language files.
>
>**Returns:**
>
>| Type | Description |
>| :-: | - |
>| `string`, `table` | The translation line. If @index is nil, then it's the translation table (index = value). If @index exists, it may be the string, or @raw string, or a table if it has gender differences ({ male, female }). It may not exist. |
---
>### client:insertPacketListener ( C, CC, f, append )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| C | `int` | ✔ | The C packet. |
>| CC | `int` | ✔ | The CC packet. |
>| f | `function` | ✔ | The function to be triggered when the @C-@CC packets are received. |
>| append | `boolean` | ✕ | 'true' if the function should be appended to the (C, CC) listener, 'false' if the function should overwrite the (C, CC) listener. <sub>(default = false)</sub> |
>
>Inserts a new function to the packet parser. The parameters are (packet, connection, identifiers).
>
---
>### client:insertOldPacketListener ( C, CC, f, append )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| C | `int` | ✔ | The C packet. |
>| CC | `int` | ✔ | The CC packet. |
>| f | `function` | ✔ | The function to be triggered when the @C-@CC packets are received. |
>| append | `boolean` | ✕ | 'true' if the function should be appended to the (C, CC) listener, 'false' if the function should overwrite the (C, CC) listener. <sub>(default = false)</sub> |
>
>Inserts a new function to the old packet parser. The parameters are (data, connection, oldIdentifiers).
>
---
>### client:insertTribulleListener ( tribulleId, f, append )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| tribulleId | `int` | ✔ | The tribulle id. |
>| f | `function` | ✔ | The function to be triggered when this tribulle packet is received. |
>| append | `boolean` | ✕ | 'true' if the function should be appended to the (C, CC, tribulle) listener, 'false' if the function should overwrite the (C, CC) listener. <sub>(default = false)</sub> |
>
>Inserts a new function to the tribulle (60, 3) packet parser. The parameters are (packet, connection, tribulleId).
>
---
>### client:joinChat ( chatName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| chatName | `string` | ✔ | The name of the chat. |
>
>Joins a #chat.
>
---
>### client:joinTribeHouse (  )
>
>Joins the tribe house (if the account is in a tribe).
>
---
>### client:kickTribeMember ( memberName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| memberName | `string` | ✔ | The name of the member to be kicked. |
>
>Kicks a tribe member from the tribe.<br>
>![/!\\](https://i.imgur.com/HQ188PK.png) Note that this method will not cover errors if the account is not in a tribe or does not have permissions.
>
---
>### client:likeCafeMessage ( topicId, messageId, dislike )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| topicId | `int` | ✔ | The id of the topic where the message is located. |
>| messageId | `int` | ✔ | The id of the message that will receive the reaction. |
>| dislike | `boolean` | ✕ | Whether the reaction must be a dislike or not. <sub>(default = false)</sub> |
>
>Likes/Dislikes a message in a Café topic.<br>
>![/!\\](https://i.imgur.com/HQ188PK.png) The method does not handle the Café's cooldown system: 300 seconds to react in a message.
>
---
>### client:loadLua ( script )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| script | `string` | ✔ | The lua script. |
>
>Loads a lua script in the room.
>
---
>### client:on ( eventName, callback )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| eventName | `string` | ✔ | The name of the event. |
>| callback | `function` | ✔ | The function that must be called when the event is triggered. |
>
>Sets an event emitter that is triggered everytime a specific behavior happens.<br>
>See the available events in [Events](Events.md).
>
---
>### client:once ( eventName, callback )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| eventName | `string` | ✔ | The name of the event. |
>| callback | `function` | ✔ | The function that must be called only once when the event is triggered. |
>
>Sets an event emitter that is triggered only once a specific behavior happens.<br>
>See the available events in [Events](Events.md).
>
---
>### client:openCafe ( close )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| close | `boolean` | ✕ | If the Café should be closed. <sub>(default = false)</sub> |
>
>Toggles the current Café state (open / close).<br>
>It will send [reloadCafe](Client.md#clientreloadcafe---) automatically if close is false.
>
---
>### client:openCafeTopic ( topicId )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| topicId | `int` | ✔ | The id of the topic to be opened. |
>
>Opens a Café topic.<br>
>You may use this method to reload (or refresh) the topic.
>
---
>### client:playEmote ( emote, flag )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| emote | `enum.emote` | ✕ | An enum from [emote](Enum.md#emote-int). (index or value) <sub>(default = dance)</sub> |
>| flag | `string` | ✕ | The country code of the flag when @emote is flag. |
>
>Plays an emote.
>
---
>### client:playEmoticon ( emoticon )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| emoticon | `enum.emoticon` | ✕ | An enum from [emoticon](Enum.md#emoticon-int). (index or value) <sub>(default = smiley)</sub> |
>
>Plays an emoticon
>
---
>### client:processXml ( process )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| process | `boolean` | ✕ | Whether map XMLs should be processed. |
>
>Toggles the field _\_process\_xml_ of the instance.<br>
>If 'true', the XML will be processed in the event _newGame_.
>
>**Returns:**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether map XMLs will be processed. |
---
>### client:recruitPlayer ( playerName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| playerName | `string` | ✔ | The name of player to be recruited. |
>
>Sends a tribe invite to a player.<br>
>![/!\\](https://i.imgur.com/HQ188PK.png) Note that this method will not cover errors if the account is not in a tribe or does not have permissions.
>
---
>### client:reloadCafe (  )
>
>Reloads the Café data.
>
---
>### client:requestBlackList (  )
>
>Requests the black list.
>
---
>### client:requestFriendList (  )
>
>Requests the friend list.
>
---
>### client:requestRoomList ( roomMode )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| roomMode | `enum.roomMode` | ✕ | An enum from [roomMode](Enum.md#roomMode-int). (index or value) <sub>(default = normal)</sub> |
>
>Requests the data of a room mode list.
>
---
>### client:removeFriend ( playerName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| playerName | `string` | ✔ | The player name to be removed from the friend list. |
>
>Removes a player from the friend list.
>
---
>### client:sendCafeMessage ( topicId, message )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| topicId | `int` | ✔ | The id of the topic where the message will be posted. |
>| message | `string` | ✔ | The message to be posted. |
>
>Sends a message in a Café topic.<br>
>![/!\\](https://i.imgur.com/HQ188PK.png) The method does not handle the Café's cooldown system: 300 seconds if the last post is from the same account, otherwise 10 seconds.
>
---
>### client:sendChatMessage ( chatName, message )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| chatName | `string` | ✔ | The name of the chat. |
>| message | `string` | ✔ | The message. |
>
>Sends a message to a #chat.<br>
>![/!\\](https://i.imgur.com/HQ188PK.png) Note that a message has a limit of 80 characters in the first 24 hours after the account creation, and 255 characters later. You must handle the limit yourself or the bot may get disconnected.
>
---
>### client:sendCommand ( command )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| command | `string` | ✔ | The command. (without /) |
>
>Sends a (/)command.
>
---
>### client:sendRoomMessage ( message )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| message | `string` | ✔ | The message. |
>
>Sends a message in the room chat.<br>
>![/!\\](https://i.imgur.com/HQ188PK.png) Note that a message has a limit of 80 characters in the first 24 hours after the account creation, and 255 characters later. You must handle the limit yourself or the bot may get disconnected.
>
>
---
>### client:sendTribeMessage ( message )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| message | `string` | ✔ | The message. |
>
>Sends a message to the tribe chat.<br>
>![/!\\](https://i.imgur.com/HQ188PK.png) Note that a message has a limit of 80 characters in the first 24 hours after the account creation, and 255 characters later. You must handle the limit yourself or the bot may get disconnected.
>
>
---
>### client:sendWhisper ( targetUser, message )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| message | `string` | ✔ | The message. |
>| targetUser | `string` | ✔ | The user who will receive the whisper. |
>
>Sends a whisper to an user.<br>
>![/!\\](https://i.imgur.com/HQ188PK.png) Note that a message has a limit of 80 characters in the first 24 hours after the account creation, and 255 characters later. You must handle the limit yourself or the bot may get disconnected.
>
---
>### client:setCommunity ( community )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| community | `string`, `int` | ✕ | An enum from [community](Enum.md#community-int). (index or value) <sub>(default = EN)</sub> |
>
>Sets the community the bot will connect to.<br>
>![/!\\](https://i.imgur.com/HQ188PK.png) This method must be called before the [start](Client.md#clientstart--self-tfmid-token-).
>
---
>### client:setTribeMemberRole ( memberName, roleId )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| memberName | `string` | ✔ | The name of the member to get the role. |
>| roleId | `int` | ✔ | The role id. (starts from 0, the initial role, and goes until the Chief role) |
>
>Sets the role of a member in the tribe.<br>
>![/!\\](https://i.imgur.com/HQ188PK.png) Note that this method will not cover errors if the account is not in a tribe or do not have permissions.
>
---
>### client:start ( tfmId, token )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| tfmId | `string`, `int` | ✔ | The Transformice ID of your account. If you don't know how to obtain it, go to the room **#bolodefchoco0id** and check your chat. |
>| token | `string` | ✔ | The API Endpoint token to get access to the authentication keys. |
>
>Initializes the API connection with the authentication keys. It must be the first method of the API to be called.
>
---
>### client:whitelistPlayer ( playerName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| playerName | `string` | ✔ | The player name to be removed from the blacklist. |
>
>Removes a player from the black list.
>
