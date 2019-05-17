# Events

Use the following structure to make events:
```Lua
client:on("event_name", function(parameters) -- replace 'on' to 'once' if you want it to be triggered only once.
	-- TODO
end)
```
---

>### cafeTopicList ( data )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| data | `table` | The data of the topics. |
>
>Triggered when the Café is opened or refreshed, and the topics are loaded partially.
>
>**@data structure**:
>```Lua
>{
>	[i] = {
>		id = 0, -- The id of the topic.
>		title = "", -- The title of the topic.
>		authorId = 0, -- The id of the topic author.
>		posts = 0, -- The quantity of messages in the topic.
>		lastUserName = "", -- The name of the last user that posted in the topic.
>		timestamp = 0, -- When the topic was created.
>
>		-- The event "cafeTopicLoad" must be triggered so the fields below exist.
>		author = "", -- The name of the topic author.
>		messages = {
>			[i] = {
>				topicId = 0, -- The id of the topic where the message is located.
>				id = 0, -- The id of the message.
>				authorId = 0, -- The id of the topic author.
>				timestamp = 0, -- When the topic was created.
>				author = "", -- The name of the topic author.
>				content = "", -- The content of the message.
>				canLike = false, -- Whether the message can be liked by the bot or not.
>				likes = 0 -- The quantity of likes in the message.
>			}
>		}
>	}
>}
>```
>
---
>### cafeTopicLoad ( topic )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| topic | `table` | The data of the topic. |
>
>Triggered when a Café topic is opened or refreshed.
>
>**@topic structure**:
>```Lua
>{
>	id = 0, -- The id of the topic.
>	title = "", -- The title of the topic.
>	authorId = 0, -- The id of the topic author.
>	posts = 0, -- The quantity of messages in the topic.
>	lastUserName = "", -- The name of the last user that posted in the topic.
>	timestamp = 0, -- When the topic was created.
>
>	-- The event "cafeTopicLoad" must be triggered so the fields below exist.
>	author = "", -- The name of the topic author.
>	messages = {
>		[i] = {
>			topicId = 0, -- The id of the topic where the message is located.
>			id = 0, -- The id of the message.
>			authorId = 0, -- The id of the topic author.
>			timestamp = 0, -- When the topic was created.
>			author = "", -- The name of the topic author.
>			content = "", -- The content of the message.
>			canLike = false, -- Whether the message can be liked by the bot or not.
>			likes = 0 -- The quantity of likes in the message.
>		}
>	}
>}
>```
>
---
>### cafeTopicMessage ( message, topic )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| message | `table`| The data of the message. |
>| topic | `table` | The data of the topic. |
>
>Triggered when a new message in a Café topic is cached.
>
>**@message structure**:
>```Lua
>{
>	topicId = 0, -- The id of the topic where the message is located.
>	id = 0, -- The id of the message.
>	authorId = 0, -- The id of the topic author.
>	timestamp = 0, -- When the topic was created.
>	author = "", -- The name of the topic author.
>	content = "", -- The content of the message.
>	canLike = false, -- Whether the message can be liked by the bot or not.
>	likes = 0 -- The quantity of likes in the message.
>}
>```
>
>**@topic structure**:
>```Lua
>{
>	id = 0, -- The id of the topic.
>	title = "", -- The title of the topic.
>	authorId = 0, -- The id of the topic author.
>	posts = 0, -- The quantity of messages in the topic.
>	lastUserName = "", -- The name of the last user that posted in the topic.
>	timestamp = 0, -- When the topic was created.
>
>	-- The event "cafeTopicLoad" must be triggered so the fields below exist.
>	author = "", -- The name of the topic author.
>	messages = {
>		[i] = {
>			topicId = 0, -- The id of the topic where the message is located.
>			id = 0, -- The id of the message.
>			authorId = 0, -- The id of the topic author.
>			timestamp = 0, -- When the topic was created.
>			author = "", -- The name of the topic author.
>			content = "", -- The content of the message.
>			canLike = false, -- Whether the message can be liked by the bot or not.
>			likes = 0 -- The quantity of likes in the message.
>		}
>	}
>}
>```
>
---
>### chatMessage ( chatName, playerName, message, playerCommunity )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| chatName | `string` | The name of the chat. |
>| playerName | `string` | The player who sent the message. |
>| message | `string` | The message. |
>| playerCommunity | `int` | The community id of @playerName. |
>
>Triggered when a #chat receives a new message.
>
---
>### chatWho ( chatName, data )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| chatName | `string` | The name of the chat. |
>| data | `table` | An array with the nicknames of the current users in the chat. |
>
>Triggered when the /who command is loaded in a chat.
>
---
>### connection (  )
>
>Triggered when the account is logged and ready to perform actions.
>
---
>### disconnection ( connection )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| connection | `connection` | The connection object. |
>
>Triggered when a connection dies or fails.
>
---
>### friendConnection ( playerName )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| playerName | `string` | The player name. |
>
>Triggered when a friend connects to the game.
>
---
>### friendDisconnection ( playerName )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| playerName | `string` | The player name. |
>
>Triggered when a friend disconnects from the game.
>
---
>### heartbeat ( time )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| time | `int` | The current time. |
>
>Triggered when a heartbeat is sent to the connection, every 10 seconds.
>
---
>### joinTribeHouse ( tribeName )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| tribeName | `string` | The name of the tribe. |
>
>Triggered when the account joins a tribe house.
>
---
>### lua ( log )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| log | `string` | The log message. |
>
>Triggered when the #lua chat receives a log message.
>
---
>### missedOldPacket ( connection, identifiers, packet )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| connection | `connection` | The connection object. |
>| identifiers | `table` | The C, CC identifiers that were not handled. |
>| packet | `bArray` | The Byte Array object with the packet that was not handled. |
>
>Triggered when an old packet is not handled by the old packet parser.
>
---
>### missedPacket ( connection, identifiers, packet )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| connection | `connection` | The connection object. |
>| identifiers | `table` | The C, CC identifiers that were not handled. |
>| packet | `bArray` | The Byte Array object with the packet that was not handled. |
>
>Triggered when an identifier is not handled by the system.
>
---
>### missedTribulle ( connection, tribulleId, packet )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| connection | `connection` | The connection object. |
>| tribulleId | `int` | The tribulle id. |
>| packet | `bArray` | The Byte Array object with the packet that was not handled. |
>
>Triggered when a tribulle packet is not handled by the tribulle packet parser.
>
---
>### newGame ( map )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| map | `table` | The new map data. |
>
>Triggered when a new map is loaded.<br>
>![/!\\](http://images.atelier801.com/168395f0cbc.png) This event may increase the memory consumption significantly due to the XML processes. Set the variable `_process_xml` as false to avoid processing it.
>
>**@map structure**:
>```Lua
>{
>	code = 0, -- The map code.
>	xml = "", -- The map XML. May be nil if the map is Vanilla.
>	author = "", -- The map author
>	perm = 0, -- The perm code of the map.
>	isMirrored = false -- Whether the map is mirrored or not.
>}
>```
>
---
>### newTribeMember ( memberName )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| memberName | `string` | The member who joined the tribe. |
>
>Triggered when a player joins the tribe.
>
---
>### ping ( )
>
>Triggered when a server heartbeat is received.
>
---
>### profileLoaded ( data )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| data | `table` | The user profile data. |
>
>Triggered when the profile of an user is loaded.
>
>**@data structure**:
>```Lua
>{
>	playerName = "", -- The player name.
>	id = 0, -- The player id.
>	registrationDate = 0, -- The timestamp of when the account was created.
>	role = 0, -- An enum from enum.role that specifies the account's role.
>	gender = 0, -- An enum from enum.gender for the account's gender. 
>	tribeName = "", -- The name of the tribe.
>	soulmate = "", -- The name of the soulmate.
>	saves = {
>		normal = 0, -- Total saves in the normal mode.
>		hard = 0, -- Total saves in the hard mode.
>		divine = 0 -- Total saves in the divine mode.
>	}, -- Total saves of the account.
>	shamanCheese = 0, -- Total of cheeses gathered as shaman.
>	firsts = 0, -- Total of firsts.
>	cheeses = 0, -- Total of cheeses.
>	bootcamps = 0, -- Total of bootcamps.
>	titleId = 0, -- The id of the current title.
>	totalTitles = 0, -- Total of unlocked titles.
>	titles = {
>		[id] = 0 -- The id of the title as index, the quantity of stars as value.
>	}, -- The list of unlocked titles.
>	look = "", -- The account's outfit code.
>	level = 0, -- The account's level.
>	totalBadges = 0, -- The total of unlocked badges.
>	badges = {
>		[id] = 0 -- The id of the badge as index, the quantity as value.
>	}, -- The list of unlocked badges.
>	totalModeStats = 0, -- The total of mode statuses.
>	modeStats = {
>		[id] = {
>			progress = 0, -- The current score in the status.
>			progressLimit = 0, -- The status score limit.
>			imageId = 0 -- The image id of the status. 
>		} -- The status id.
>	}, -- The list of mode statuses.
>	orbId = 0, -- The id of the current shaman orb.
>	totalOrbs = 0, -- The total of unlocked shaman orbs.
>	orbs = {
>		[id] = true -- The id of the shaman orb as index.
>	}, -- The list of unlocked shaman orbs.
>	adventurePoints = 0 -- The total adventure points.
>}
>```
>
---
>### ready (  )
>
>Triggered when the connection is live.
>
---
>### receive ( connection, packet, identifiers )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| connection | `connection` | The connection object that received the packets. |
>| packet | `bArray` | The Byte Array object that was received. |
>| identifiers | `table` | The C, CC identifiers that were received. |
>
>Triggered when the client receives packets from the server.
>
---
>### roomChanged ( roomName, isPrivateRoom )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| roomName | `string` | The name of the room. |
>| isPrivateRoom | `boolean` | Whether the room is only accessible by the account or not. |
>
>Triggered when the account changes the room.
>
---
>### roomList ( roomMode, rooms, pinned )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| roomMode | `int`| The id of the room mode. |
>| rooms | `table` | The data of the rooms in the list. |
>| pinned | `table` | The data of the pinned objects in the list. |
>
>Triggered when the room list of a mode is loaded.
>
>**@rooms structure**:
>```Lua
>{
>	[n] = {
>		name = "", -- The name of the room.
>		totalPlayers = 0, -- The quantity of players in the room.
>		maxPlayers = 0, -- The maximum quantity of players the room can get.
>		onFuncorpMode = false -- Whether the room is having a funcorp event (orange name) or not.
>	}
>}
>```
>
>**@pinned structure**:
>```Lua
>{
>	[n] = {
>		name = "", -- The name of the object.
>		totalPlayers = 0 -- The quantity of players in the object counter.
>	}
>}
>```
>
---
>### roomMessage ( playerName, message, playerCommunity, playerId )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| playerName | `string` | The player who sent the message. |
>| message | `string` | The message. |
>| playerCommunity | `int` | The community id of @playerName. |
>| playerId | `int` | The temporary id of @playerName. |
>
>Triggered when the room receives a new user message.
>
---
>### send ( identifiers, packet )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| identifiers | `table` | The C, CC identifiers sent in the request. |
>| packet | `bArray` | The Byte Array object that was sent. |
>
>Triggered when the client sends packets to the server.
>
---
>### staffList ( list )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| list | `string` | The staff list content. |
>
>Triggered when a staff list is loaded (/mod, /mapcrew).
>
---
>### time ( time )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| time | `table` | The account's time data. |
>
>Triggered when the command /time is requested.
>
>**@time structure**:
>```Lua
>{
>	day = 0, -- Total days
>	hour = 0, -- Total hours
>	minute = 0, -- Total minutes
>	second = 0 -- Total seconds
>}
>```
>
---
>### tribeMemberConnection ( memberName )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| memberName | `string` | The member name. |
>
>Triggered when a tribe member connects to the game.
>
---
>### tribeMemberDisconnection ( memberName )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| memberName | `string` | The member name. |
>
>Triggered when a tribe member disconnects to the game.
>
---
>### tribeMemberGetRole ( memberName, setterName, role )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| memberName | `string` | The member name. |
>| setterName | `string` | The name of who set the role to the member. |
>| role | `string` | The role name. |
>
>Triggered when a tribe member gets a role.
>
---
>### tribeMemberKick ( memberName, kickerName )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| memberName | `string` | The member name. |
>| kickerName | `string` | The name of who kicked the member. |
>
>Triggered when a tribe member is kicked.
>
---
>### tribeMemberLeave ( memberName )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| memberName | `string` | The member who left the tribe. |
>
>Triggered when a member leaves the tribe.
>
---
>### tribeMessage ( memberName, message )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| memberName | `string` | The member who sent the message. |
>| message | `string` | The message. |
>
>Triggered when the tribe chat receives a new message.
>
---
>### unreadCafeMessage ( topicId, topic )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| topicId | `int` | The id of the topic where the new messages were posted. |
>| topic | `table` | The data of the topic. It **may be** nil. |
>
>Triggered when new messages are posted on Café.
>
>**@topic structure**:
>```Lua
>{
>	id = 0, -- The id of the topic.
>	title = "", -- The title of the topic.
>	authorId = 0, -- The id of the topic author.
>	posts = 0, -- The quantity of messages in the topic.
>	lastUserName = "", -- The name of the last user that posted in the topic.
>	timestamp = 0, -- When the topic was created.
>	
>	-- The event "cafeTopicLoad" must be triggered so the fields below exist.
>	author = "", -- The name of the topic author.
>	messages = {
>		-- This might not include the unread message.
>		[i] = {
>			topicId = 0, -- The id of the topic where the message is located.
>			id = 0, -- The id of the message.
>			authorId = 0, -- The id of the topic author.
>			timestamp = 0, -- When the topic was created.
>			author = "", -- The name of the topic author.
>			content = "", -- The content of the message.
>			canLike = false, -- Whether the message can be liked by the bot or not.
>			likes = 0 -- The quantity of likes in the message.
>		}
>	}
>}
>```
>
---
>### whisperMessage ( playerName, message, playerCommunity )
>| Parameter | Type | Description |
>| :-: | :-: | - |
>| playerName | `string` | Who sent the whisper message. |
>| message | `string` | The message. |
>| playerCommunity | `int` | The community id of @playerName. |
>
>Triggered when the account receives a whisper.
>
---