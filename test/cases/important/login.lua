local transfromage = require("transfromage")
local client = transfromage.Client()

args[2] = string.toNickname(args[2], true)

client:once("ready", function(onlinePlayers, country, language)
	assert(onlinePlayers)
	assert(country and country ~= '')
	assert(language and language ~= '')

	client:connect(args[2], args[3])
end)

client:once("connection", function(playerId, playerName, playedTime)
	assert(playerId)
	assert(playerName and playerName ~= '')
	assert(playedTime)

	assert(playerName == args[2])

	client:disconnect()
	os.exit()
end)

client:start(args[4], args[5])