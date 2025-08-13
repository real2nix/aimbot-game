--[[
	@class ServerMain
]]
local ServerScriptService = game:GetService("ServerScriptService")

local loader = ServerScriptService.Aimbot:FindFirstChild("LoaderUtils", true).Parent
local require = require(loader).bootstrapGame(ServerScriptService.Aimbot)

local serviceBag = require("ServiceBag").new()
serviceBag:GetService(require("CmdrService"))
serviceBag:GetService(require("RagdollService"))
serviceBag:GetService(require("AimbotTranslator"))
serviceBag:GetService(require("ActivePlayersService"))
serviceBag:GetService(require("GunService"))
serviceBag:GetService(require("DeathService"))
serviceBag:GetService(require("SpawnPlayerService"))
serviceBag:GetService(require("PlayersScoreService"))
serviceBag:GetService(require("PlayerHurtService"))
serviceBag:GetService(require("PlayersCollisionService"))
serviceBag:GetService(require("RoundControllerService"))
serviceBag:Init()
serviceBag:Start()
