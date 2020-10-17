local testChat
local receivedMessages = 0

local transfromage = require("transfromage")
local client = transfromage.Client()

args[2] = string.toNickname(args[2], true)

client:once("ready", function(onlinePlayers, country, language)
	client:connect(args[2], args[3])
end)

client:once("connection", function(playerId, playerName, playedTime)
	client:sendRoomMessage("666")

	testChat = client.chatList:get("transfromage-api-test")
	testChat:sendMessage("69")
	testChat:close()

	client:sendWhisper(client.playerName, "911")

	require("timer").setTimeout(1500, function()
		assert(receivedMessages == 3, 'has ' .. receivedMessages)

		client:disconnect()
		os.exit()
	end)
end)

client:on("roomMessage", function(playerName, message)
	if playerName == client.playerName then
		assert(message == "666")

		receivedMessages = receivedMessages + 1
	end
end)

client:on("chatMessage", function(chatName, playerName, message, playerCommunity)
	if playerName == client.playerName then
		assert(chatName == testChat.name)
		assert(message == "69")
		assert(playerCommunity == transfromage.enum.chatCommunity.br)

		receivedMessages = receivedMessages + 1
	end
end)

client:on("whisperMessage", function(playerName, message, playerCommunity)
	if playerName == client.playerName then
		assert(message == "911")
		assert(playerCommunity == transfromage.enum.chatCommunity.br)

		receivedMessages = receivedMessages + 1
	end
end)

client:setLanguage(transfromage.enum.language.br)
client:start(args[4], args[5])