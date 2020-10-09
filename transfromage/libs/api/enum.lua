------------------------------------------- Optimization -------------------------------------------
local require = require
----------------------------------------------------------------------------------------------------

local enum = require("./enum/init")

require("./enum/validators")

require("utils/folderLoader")("api/enum/enums")

return enum