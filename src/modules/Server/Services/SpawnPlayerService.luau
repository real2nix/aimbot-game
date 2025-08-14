local Players = game:GetService("Players")
local require = require(script.Parent.loader).load(script)

local SpawnPlayerService = {}
SpawnPlayerService.ServiceName = "SpawnPlayerService"

local Maid = require("Maid")
local Promise = require("Promise")
local CharacterUtils = require("CharacterUtils")
local GetRemoteEvent = require("GetRemoteEvent")
local RxCharacterUtils = require("RxCharacterUtils")

local FORCEFIELD_SECONDS: number = 2
local REMOTE_EVENT_NAME: string = "SpawnPlayerService"

function SpawnPlayerService.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._deathService = serviceBag:GetService(require("DeathService"))
	self._activePlayersService = serviceBag:GetService(require("ActivePlayersService"))
	self._spawnPoints = workspace.Spawns:GetChildren()
	self._remoteEvent = GetRemoteEvent(REMOTE_EVENT_NAME)
end

function SpawnPlayerService.Start(self)
	self._maid:Add(self._deathService.playerDiedSignal:Connect(function(player)
		Promise.delay(5, function()
			self:_addForcefield(player)
			self:_spawnPlayer(player)
			self._remoteEvent:FireClient(player, {
				message = "spawn",
			})
		end)
	end))
	self._maid:Add(self._activePlayersService.playerAdded:Connect(function(player)
		self:_addForcefield(player)
		RxCharacterUtils.observeCharacter(player):Subscribe(function(character)
			self:_spawnPlayer(player)
		end)
	end))
end

function SpawnPlayerService.Destroy(self)
	self._maid:DoCleaning()
end

function SpawnPlayerService._spawnPlayer(self, player)
	if not player.Character then
		return
	end
	player.Character:PivotTo(self:_getPlayerSpawn(player).CFrame * CFrame.new(0, 5, 0))
end

function SpawnPlayerService._getPlayerSpawn(self, player)
	local rootPart = CharacterUtils.getPlayerRootPart(player)
	if not rootPart then
		return self._spawnPoints[#self._spawnPoints]
	end
	local spawnScores = {}
	for _, spawn in self._spawnPoints do
		local score = 0
		for _, otherPlayer in Players:GetPlayers() do
			local otherRootPart = CharacterUtils.getPlayerRootPart(otherPlayer)
			if not otherRootPart then
				continue
			end
			score += (spawn.Position - otherRootPart.Position).Magnitude
		end
		table.insert(spawnScores, {
			spawn = spawn,
			score = score,
		})
	end
	table.sort(spawnScores, function(a, b)
		return a.score > b.score
	end)
	return spawnScores[1].spawn
end

function SpawnPlayerService._addForcefield(self, player: Player)
	-- Player has left
	if not self._activePlayersService.activePlayers[player] then
		return
	end
	self._activePlayersService.activePlayers[player].forcefield = true
	self._activePlayersService.activePlayers[player].health.Value = 150

	Promise.delay(FORCEFIELD_SECONDS, function()
		if not self._activePlayersService.activePlayers[player] then
			return
		end
		self._activePlayersService.activePlayers[player].forcefield = false
	end)
end

return SpawnPlayerService
