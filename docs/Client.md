# Methods
>### client:changeWhisperState ( message, state )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| message | `string` | ✕ | The /silence message. <sub>(default = '')</sub> |
>| state | `enum.whisperState` | ✕ | An enum from [whisperState](Enum.md#whisperstate-int). (index or value) <sub>(default = enabled)</sub> |
>
>Sets the account's whisper state.
>
---
>### client:chatWho ( chatName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| chatName | `string` | ✔ | The name of the chat. |
>
>Gets who is in a specific chat. (/who)
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
>| startRoom | `string` | ✕ | The name of the initial room. <sub>(default = \*#bolodefchoco)</sub> |
>| timeout | `int` | ✕ | The time in ms to throw a timeout error if the connection takes too long to succeed. <sub>(default = 20000)</sub> |
>
>Connects to an account in-game.<br>
>It will try to connect using all the available ports before throwing a timing out error.
>
---
>### client:connectionTime ( )
>Gets the total time of the connection.
>
>**Returns:**
>| Type | Description |
>| :-: | - |
>| `int` | The total time since the connection. |
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
>Enters in a room.
>
---
>### client:insertReceiveFunction ( C, CC, f )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| C | `int` | ✔ | The C packet. |
>| CC | `int` | ✔ | The CC packet. |
>| f | `function` | ✔ | The function to be triggered when the @C-@CC packets are received. |
>
>Inserts a new function to the packet parser.
>
---
>### client:insertTribulleFunction ( tribulleId, f )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| tribulleId | `int` | ✔ | The tribulle id. |
>| f | `function` | ✔ | The function to be triggered when this tribulle packet is received. |
>
>Inserts a new function to the tribulle (60, 3) packet parser.
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
>### client:joinTribeHouse ( )
>
>Joins the tribe house, if the account is in a tribe.
>
---
>### client:kickTribeMember ( memberName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| memberName | `string` | ✔ | The name of the member to be kicked. |
>
>Kicks a member of the tribe.<br>
>![/!\\](http://images.atelier801.com/168395f0cbc.png) Note that this method will not cover errors if the account is not in a tribe or do not have permissions.
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
>Sets an event emitter that is triggered everytime the specific behavior happens.<br>
>See the available events in [Events](Events.md).
>
---
>### client:once ( eventName, callback )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| eventName | `string` | ✔ | The name of the event. |
>| callback | `function` | ✔ | The function that must be called only once when the event is triggered. |
>
>Sets an event emitter that is triggered only once when a specific behavior happens.<br>
>See the available events in [Events](Events.md).
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
>### client:recruitPlayer ( playerName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| playerName | `string` | ✔ | The name of player to be recruited. |
>
>Sends a recruitment invite to the player.<br>
>![/!\\](http://images.atelier801.com/168395f0cbc.png) Note that this method will not cover errors if the account is not in a tribe or do not have permissions.
>
---
>### client:sendChatMessage ( chatName, message )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| chatName | `string` | ✔ | The name of the chat. |
>| message | `string` | ✔ | The message. |
>
>Sends a message to a #chat.<br>
>![/!\\](http://images.atelier801.com/168395f0cbc.png) Note that the limit of characters for the message is 255, but if the account is new the limit is set to 80. You must limit it yourself or the bot may get disconnected.
>
---
>### client:sendCommand ( command )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| command | `string` | ✔ | The command. (without /) |
>
>Sends a command (/).
>
---
>### client:sendRoomMessage ( message )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| message | `string` | ✔ | The message. |
>
>Sends a message in the room chat.<br>
>![/!\\](http://images.atelier801.com/168395f0cbc.png) Note that the limit of characters for the message is 255, but if the account is new the limit is set to 80. You must limit it yourself or the bot may get disconnected.
>
---
>### client:sendTribeMessage ( message )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| message | `string` | ✔ | The message. |
>
>Sends a message to the tribe chat.<br>
>![/!\\](http://images.atelier801.com/168395f0cbc.png) Note that the limit of characters for the message is 255, but if the account is new the limit is set to 80. You must limit it yourself or the bot may get disconnected.
>
---
>### client:sendWhisper ( targetUser, message )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| message | `string` | ✔ | The message. |
>| targetUser | `string` | ✔ | The user to receive the whisper. |
>
>Sends a whisper to an user.<br>
>![/!\\](http://images.atelier801.com/168395f0cbc.png) Note that the limit of characters for the message is 255, but if the account is new the limit is set to 80. You must limit it yourself or the bot may get disconnected.
>
---
>### client:setCommunity ( community )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| community | `string`, `int` | ✔ | An enum from [community](Enum.md#community-int). (index or value) <sub>(default = EN)</sub> |
>
>Sets the community where the bot will be cpmmected to.<br>
>![/!\\](http://images.atelier801.com/168395f0cbc.png) This method must be called before the [start](Client.md#clientstart--self-tfmid-token-).
>
---
>### client:setTribeMemberRole ( memberName, roleId )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| memberName | `string` | ✔ | The name of the member to get the role. |
>| roleId | `int` | ✔ | The role id. (starts in 0, for the initial role. Increases until the Chief role) |
>
>Sets the role of a member in the tribe.<br>
>![/!\\](http://images.atelier801.com/168395f0cbc.png) Note that this method will not cover errors if the account is not in a tribe or do not have permissions.
>
---
>### client:start ( tfmId, token )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| tfmId | `string`, `int` | ✔ | The Transformice ID of your account. If you don't know how to obtain it, go to the room **#bolodefchoco0id** and check your chat. |
>| token | `string` | ✔ | The API Endpoint token to get access to the authentication keys. Learn more in |
>
>Initializes the API connection with the authentication keys. It must be the first method of the API to be called.
>
---