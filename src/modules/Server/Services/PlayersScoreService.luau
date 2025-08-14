local require = require(script.Parent.loader).load(script)

local PlayersScoreService = {}
PlayersScoreService.ServiceName = "PlayersScoreService"

local Maid = require("Maid")
local GetRemoteEvent = require("GetRemoteEvent")

local REMOTE_EVENT_NAME = "PlayersScoreService"

function PlayersScoreService.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._gunService = serviceBag:GetService(require("GunService"))
	self._activePlayersService = serviceBag:GetService(require("ActivePlayersService"))
	self._roundControllerService = serviceBag:GetService(require("RoundControllerService"))
	self._remoteEvent = GetRemoteEvent(REMOTE_EVENT_NAME)

	-- Public
	self.playersScore = {}
end

function PlayersScoreService.Start(self)
	self._maid:Add(self._gunService.playerDiedSignal:Connect(function(data)
		self.playersScore[data.playerShooter] += 1
		self._remoteEvent:FireAllClients({
			message = "update",
			userId = data.playerShooter.UserId,
			score = self.playersScore[data.playerShooter],
		})
	end))
	self._maid:Add(self._activePlayersService.playerAdded:Connect(function(player)
		self.playersScore[player] = 0
		self._remoteEvent:FireAllClients({
			message = "update",
			userId = player.UserId,
			score = 0,
		})
	end))
	self._maid:Add(self._activePlayersService.playerRemoved:Connect(function(player)
		self.playersScore[player] = nil
	end))
	self._maid:Add(self._remoteEvent.OnServerEvent:Connect(function(player, data)
		local filteredTable = {}
		for otherPlayer, score in self.playersScore do
			filteredTable[otherPlayer.UserId] = score
		end
		if data.message == "init" then
			self._remoteEvent:FireClient(player, {
				message = "init",
				players = filteredTable,
			})
		end
	end))
	self._maid:Add(self._roundControllerService.startRound:Connect(function()
		for key in self.playersScore do
			self.playersScore[key] = 0
		end
	end))
end

function PlayersScoreService.Destroy(self)
	self._maid:DoCleaning()
end

return PlayersScoreService
