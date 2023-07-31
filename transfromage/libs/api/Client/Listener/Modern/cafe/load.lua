local onCafeLoad = function(self, packet, connection, identifiers)
	self.cafe:loadTopics(packet)

	--[[@
		@name cafeTopicList
		@desc Triggered when the Café is opened or refreshed, and the topics are loaded partially.
		@param data<table> The data of the topics.
		@struct @data
		{
			[x] = {
				id = 0, -- The id of the topic.
				title = "", -- The title of the topic.
				authorId = 0, -- The id of the topic author.
				posts = 0, -- The number of messages in the topic.
				lastUserName = "", -- The name of the last user that posted in the topic.
				timestamp = 0, -- When the topic was created.

				-- The event "cafeTopicLoad" must be triggered so the fields below exist.
				author = "", -- The name of the topic author.
				messages = {
					[i] = {
						topicId = 0, -- The id of the topic where the message is located.
						id = 0, -- The id of the message.
						authorId = 0, -- The id of the topic author.
						timestamp = 0, -- When the topic was created.
						author = "", -- The name of the topic author.
						content = "", -- The content of the message.
						canLike = false, -- Whether the account can like/dislike the message.
						likes = 0 -- The number of likes on the message.
					}
				}
			}
		}
	]]
	self.event:emit("cafeTopicList", self.cafe.topics)
end

return { onCafeLoad, 30, 40 }