local enum = require("api/enum/init")

enum.logMessage = enum {
	deprecatedMethod = "↑failure↓[/!\\]↑ ↑highlight↓%s↑ is deprecated, use ↑highlight↓%s↑ instead.",
	newVersion       = "↑info↓[UPDATE]↑ New version ↑highlight↓Transfromage@%s↑ available.",
	confirmUpdate    = "↑info↓[UPDATE]↑ Update it now? ( ↑success↓Y↑ / ↑error↓N↑ )"
}