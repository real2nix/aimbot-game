local require = require(script.Parent.loader).load(script)

local PlayersCollisionService = {}
PlayersCollisionService.ServiceName = "PlayersCollisionService"

local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

local Maid = require("Maid")

function PlayersCollisionService.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()

	-- Public
end

local function setCharacterCollisionGroup(character: Model)
	for _, part in character:GetChildren() do
		if part:IsA("BasePart") then
			part.CollisionGroup = "characters"
		end
	end
end

function PlayersCollisionService.Start(self)
	PhysicsService:RegisterCollisionGroup("characters")
	PhysicsService:CollisionGroupSetCollidable("characters", "characters", false)

	for _, player in Players:GetPlayers() do
		if player.Character then
			setCharacterCollisionGroup(player.Character)
		end
		player.CharacterAdded:Connect(setCharacterCollisionGroup)
	end
	self._maid:Add(Players.PlayerAdded:Connect(function(player: Player)
		player.CharacterAdded:Connect(setCharacterCollisionGroup)
	end))
end

function PlayersCollisionService.Destroy(self)
	self._maid:DoCleaning()
end

return PlayersCollisionService
