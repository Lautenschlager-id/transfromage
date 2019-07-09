-- Using v1.5.1
-- This bot is going to send a greeting message
-- to anyone that joins the room

local transfromage = require("transfromage")
local client = transfromage.client()
client._handle_players = true -- Handles players

client:once("ready", function()
	print("Ready to connect!")
	client:connect("Username#0000", "password", 1) -- Joins the room 1
end)

client:once("connection", function()
	print("Connected!")
end)

client:on("newPlayer", function(playerData)
	client:sendRoomMessage("Hey, " .. playerData.playerName .. "! Nice to meet you o/")
end)

client:start("PLAYER_ID", "API_TOKEN")
