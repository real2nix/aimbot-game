--[[
	@class AimbotTranslator
]]

local require = require(script.Parent.loader).load(script)

return require("JSONTranslator").new("AimbotTranslator", "en", {
	gameName = "Aimbot";
})