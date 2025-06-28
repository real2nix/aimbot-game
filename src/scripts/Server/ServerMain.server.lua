--[[
	@class ServerMain
]]
local ServerScriptService = game:GetService("ServerScriptService")

local loader = ServerScriptService.Aimbot:FindFirstChild("LoaderUtils", true).Parent
local require = require(loader).bootstrapGame(ServerScriptService.Aimbot)

local serviceBag = require("ServiceBag").new()
serviceBag:GetService(require("Entry"))
serviceBag:Init()
serviceBag:Start()
