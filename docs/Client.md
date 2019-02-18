# Methods
>### client.start ( self, tfmId, token )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| tfmId | `string`, `int` | ✔ | The Transformice ID of your account. If you don't know how to obtain it, go to the room **#bolodefchoco0id** and check your chat. |
>| token | `string` | ✔ | The API Endpoint token to get access to the authentication keys. Learn more in |
>
>Initializes the API connection with the authentication keys. It must be the first method of the API to be called.
>
---
>### client.on ( self, eventName, callback )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| eventName | `string` | ✔ | The name of the event. |
>| callback | `function` | ✔ | The function that must be called when the event is triggered. |
>
>Sets an event emitter that is triggered everytime the specific behavior happens.<br>
>See the available events in Events.
>
---
>### client.once ( self, eventName, callback )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| eventName | `string` | ✔ | The name of the event. |
>| callback | `function` | ✔ | The function that must be called only once when the event is triggered. |
>
>Sets an event emitter that is triggered only once when a specific behavior happens.<br>
>See the available events in Events.
>
---
>### client.setCommunity ( self, community )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| community | `string`, `int` | ✔ | An enum from [community](Enum.md#community-int). (index or value) <sub>(default = EN)</sub> |
>
>Sets the community where the bot will be cpmmected to.<br>
>![/!\\](http://images.atelier801.com/168395f0cbc.png) This method must be called before the [start](Client.md#clientstart--self-tfmid-token-).
>
---
>### client.connect ( self, userName, userPassword, startRoom )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| userName | `string` | ✔ | The name of the account. It must contain the discriminator tag (#). |
>| userPassword | `string` | ✔ | The password of the account. |
>| startRoom | `string` | ✕ | The name of the initial room. <sub>(default = \*#bolodefchoco)</sub> |
>
>Connects to an account in-game.<br>
>It will try to connect using all the available ports before throwing a timing out error.
>
---
>### client.sendRoomMessage ( self, message )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| message | `string` | ✔ | The message. |
>
>Sends a message in the room chat.<br>
>![/!\\](http://images.atelier801.com/168395f0cbc.png) Note that the limit of characters for the message is 255, but if the account is new the limit is set to 80. You must limit it yourself or the bot may get disconnected.
>
---
>### client.sendWhisper ( self, targetUser, message )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| message | `string` | ✔ | The message. |
>| targetUser | `string` | ✔ | The user to receive the whisper. |
>| message | `string` | ✔ | The message. |
>
>Sends a whisper to an user.<br>
>![/!\\](http://images.atelier801.com/168395f0cbc.png) Note that the limit of characters for the message is 255, but if the account is new the limit is set to 80. You must limit it yourself or the bot may get disconnected.
>
---
>### client.joinChat ( self, chatName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| chatName | `string` | ✔ | The name of the chat. |
>
>Joins a #chat.
>
---
>### client.closeChat ( self, chatName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| chatName | `string` | ✔ | The name of the chat. |
>
>Leaves a #chat.
>
---
>### client.sendChatMessage ( self, chatName, message )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| chatName | `string` | ✔ | The name of the chat. |
>| message | `string` | ✔ | The message. |
>
>Sends a message to a #chat.<br>
>![/!\\](http://images.atelier801.com/168395f0cbc.png) Note that the limit of characters for the message is 255, but if the account is new the limit is set to 80. You must limit it yourself or the bot may get disconnected.
>
---
---
>### client.sendTribeMessage ( self, message )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| message | `string` | ✔ | The message. |
>
>Sends a message to the tribe chat.<br>
>![/!\\](http://images.atelier801.com/168395f0cbc.png) Note that the limit of characters for the message is 255, but if the account is new the limit is set to 80. You must limit it yourself or the bot may get disconnected.
>
---
>### client.joinTribeHouse ( self )
>
>Joins the tribe house, if the account is in a tribe.
>
---
>### client.enterRoom ( self, roomName, isSalonAuto )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| roomName | `string` | ✔ | The name of the room. |
>| isSalonAuto | `boolean` | ✕ | Whether the change room must be /salonauto or not. <sub>(default = false)</sub> |
>
>Enters in a room.
>
---
>### client.sendCommand ( self, command )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| command | `string` | ✔ | The command. (without /) |
>
>Sends a command (/).
>
---
>### client.changeWhisperState ( self, message, state )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| message | `string` | ✕ | The /silence message. <sub>(default = '')</sub> |
>| state | `enum.whisperState` | ✕ | An enum from [whisperState](Enum.md#whisperstate-int). (index or value) <sub>(default = enabled)</sub> |
>
>Sets the account's whisper state.
>
---
>### client.loadLua ( self, script )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| script | `string` | ✔ | The lua script. |
>
>Loads a lua script in the room.
>
---
>### client.playEmote ( self, emote, flag )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| emote | `enum.emote` | ✕ | An enum from @see emote. (index or value) <sub>(default = dance)</sub> |
>| flag | `string` | ✕ | The country code of the flag when @emote is flag. |
>
>Plays an emote.
>
---
>### client.playEmoticon ( self, emoticon )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| emoticon | `enum.emoticon` | ✕ | An enum from @see emoticon. (index or value) <sub>(default = smiley)</sub> |
>
>Plays an emoticon
>