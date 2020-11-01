local onCafeUnreadMessage = function(self, packet, connection, identifiers)
	local topicId = packet:read32()

	--[[@
		@name unreadCafeMessage
		@desc Triggered when new messages are posted on Café.
		@param topicId<int> The id of the topic where the new messages were posted.
		@param topic<table> The data of the topic. It **may be** nil.
		@struct @topic
		{
			id = 0, -- The id of the topic.
			title = "", -- The title of the topic.
			authorId = 0, -- The id of the topic author.
			posts = 0, -- The number of messages in the topic.
			lastUserName = "", -- The name of the last user that posted in the topic.
			timestamp = 0, -- When the topic was created.

			-- The event "cafeTopicLoad" must be triggered so the fields below exist.
			author = "", -- The name of the topic author.
			messages = {
				-- This might not include the unread message.
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
	]]
	self.event:emit("unreadCafeMessage", topicId, self.cafe.topicsById[topicId])
end

return { onCafeUnreadMessage, 30, 44 }