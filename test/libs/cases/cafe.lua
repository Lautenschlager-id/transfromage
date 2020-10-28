require("wrapper")(function(test, transfromage, client)
	test("get cafe data", function(expect)
		local listLoaded = false

		client:on("cafeTopicList", expect(function(topics)
			p("Received event cafeTopicList")

			assert_eq(type(topics), "table", "type(t)")

			assert(#topics > 0)
			assert_eq(tostring(topics[1]), "CafeTopic", "str(t[1])")

			local topic
			for t = 1, #topics do
				topic = topics[t]
				t = "t[" .. t .. "]."
				assert_neq(topic._client, nil, t .. "_client")
				assert_neq(topic.id, nil, t .. "id")
				assert_neq(topic.title, nil, t .. "title")
				assert_neq(topic.authorId, nil, t .. "authorId")
				assert_neq(topic.posts, nil, t .. "posts")
				assert_neq(topic.lastUserName, nil, t .. "lastUserName")
				assert_neq(topic.timestamp, nil, t .. "timestamp")
			end

			if not listLoaded then
				listLoaded = true

				p("Reloading cafe")
				client:reloadCafe()
			else
				p("Closing cafe")
				client:openCafe(false)
			end
		end, 2))

		p("Opening cafe")
		client:openCafe()
	end)

	test("open cafe topic", function(expect)
		client:on("cafeTopicList", expect(function(topics)
			p("Received event cafeTopicList")

			assert(#topics > 0)

			p("Opening cafe topic")
			client:openCafeTopic(topics[1])
		end))

		client:on("cafeTopicLoad", expect(function(topic)
			p("Received event cafeTopicLoad")

			assert(topic._client)
			assert(topic.id)
			assert(topic.title)
			assert(topic.authorId)
			assert(topic.posts)
			assert(topic.lastUserName)
			assert(topic.timestamp)

			assert_eq(type(topic.messages), "table", "type(t)")

			local totalMessages = #topic.messages
			assert(totalMessages > 0)

			assert(topic.author)

			assert_eq(tostring(topic.messages[1]), "CafeMessage", "str(t[1])")

			local message
			for m = 1, totalMessages do
				message = topic.messages[m]
				m = "t[" .. m .. "]."
				assert_neq(message._client, nil, m .. "_client")
				assert_neq(message.id, nil, m .. "id")
				assert_neq(message.topicId, nil, m .. "topicId")
				assert_neq(message.authorId, nil, m .. "authorId")
				assert_neq(message.timestamp, nil, m .. "timestamp")
				assert_neq(message.author, nil, m .. "author")
				assert_neq(message.content, nil, m .. "content")
				assert_neq(message.canLike, nil, m .. "canLike")
				assert_neq(message.likes, nil, m .. "likes")
			end

			client:on("cafeTopicMessage", expect(function(evt_msg_message, evt_msg_topic)
				p("Received event cafeTopicMessage")

				assert_eq(evt_msg_topic.id, topic.id, "t.id")
				assert(evt_msg_message.likes)

				totalMessages = totalMessages - 1
				if totalMessages == 0 then
					p("Closing cafe")
					client:openCafe(false)
				end
			end, totalMessages))
		end))

		p("Opening cafe")
		client:openCafe()
	end)

	test("cafe messages", TO_DO) -- like message, new message, unread message

	local Cafe = client.cafe

	test("get cafe data (OO)", function(expect)
		local listLoaded = false

		client:on("cafeTopicList", expect(function(topics)
			p("Received event cafeTopicList")

			if not listLoaded then
				listLoaded = true

				p("Reloading cafe")
				Cafe:reload()
			else
				p("Closing cafe")
				Cafe:close()
			end
		end, 2))

		p("Opening cafe")
		Cafe:open()
	end)

	test("open cafe topic (OO)", function(expect)
		client:on("cafeTopicList", expect(function(topics)
			p("Received event cafeTopicList")

			assert(#topics > 0)

			p("Opening cafe topic")
			Cafe:openTopic(topics[1])
		end))

		client:on("cafeTopicLoad", expect(function(topic)
			p("Received event cafeTopicLoad")

			local totalMessages = #topic.messages
			assert(totalMessages > 0)

			client:on("cafeTopicMessage", expect(function(evt_msg_message, evt_msg_topic)
				p("Received event cafeTopicMessage")

				totalMessages = totalMessages - 1
				if totalMessages == 0 then
					p("Closing cafe")
					Cafe:close()
				end
			end, totalMessages))
		end))

		p("Opening cafe")
		Cafe:open()
	end)

	test("cafe messages (OO)", TO_DO)
end)