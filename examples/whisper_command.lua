-- Using v1.5.0
-- This bot is going to log in the community ES
-- and reply people that whisper it with "chilli"

local transfromage = require("transfromage")
local client = transfromage.client()

client:once("ready", function()
	print("Ready to connect!")
	client:connect("NICKNAME#0000", "PASSWORD")
end)

client:once("connection", function()
	print("Connected!")
end)

client:on("whisperMessage", function(playerName, message)
	if string.lower(message) == "chilli" then
		client:sendWhisper(playerName, "¡Si, me gusta mucho!")
	end
end)

client:setCommunity(transfromage.enum.community.es)
client:start("PLAYER_ID", "API_TOKEN")
