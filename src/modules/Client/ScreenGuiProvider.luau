local require = require(script.Parent.loader).load(script)

local GenericScreenGuiProvider = require("GenericScreenGuiProvider")

return GenericScreenGuiProvider.new({
	HEALTH = 1,
	RELOAD_COUNTDOWN = 1,
	CROSSHAIR = 2,
	AIMBOT_LINES = 1,
	HITMARKER = 3,
	AMMO = 1,
	DAMAGE_INDICATOR = 2,
	ELIMINATIONS = 1,
})
