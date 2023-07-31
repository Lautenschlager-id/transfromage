local enum = require("api/enum/init")

--[[@
	@name game
	@desc The ID of each game.
	@type int
]]
enum.game = enum {
	unknown      = 00,
	none         = 01,
	transformice = 04,
	fortoresse   = 06,
	bouboum      = 07,
	nekodancer   = 15,
	deadmaze     = 17
}

--[[@
	@name roomMode
	@desc The available room modes.
	@type int
]]
enum.roomMode = enum {
	normal     = 01,
	bootcamp   = 02,
	vanilla    = 03,
	survivor   = 08,
	racing     = 09,
	defilante  = 10,
	shaman     = 13,
	village    = 16,
	module     = 18,
	madchess   = 20,
	celousco   = 22,
	bouboum    = 30,
	ranked     = 31,
	duel       = 33,
	arena      = 34,
	domination = 42
}

enum.profileStats = enum {
	survivorRoundsPlayed     = 26,
	survivorShaman           = 27,
	survivorKills            = 28,
	survivorRoundsSurvived   = 29,
	racingRoundsPlayed       = 30,
	racingRoundsCompleted    = 31,
	racingFirst              = 32,
	racingPodium             = 33,
	defilanteRoundsPlayed    = 42,
	defilanteRoundsCompleted = 43,
	defilantePoints          = 44
}