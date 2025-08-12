local require = require(script.Parent.loader).load(script)

local PlayersScoreServiceClient = {}
PlayersScoreServiceClient.ServiceName = "PlayersScoreServiceClient"

local Maid = require("Maid")
local PromiseGetRemoteEvent = require("PromiseGetRemoteEvent")
local ValueObject = require("ValueObject")
local Signal = require("Signal")

local REMOTE_EVENT_NAME = "PlayersScoreService"

function PlayersScoreServiceClient.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._remoteEvent = PromiseGetRemoteEvent(REMOTE_EVENT_NAME)
	self._activePlayersServiceClient = serviceBag:GetService(require("ActivePlayersServiceClient"))
	self._roundControllerServiceClient = serviceBag:GetService(require("RoundControllerServiceClient"))

	-- Public
	self.playersScores = {}
	self.playerAdded = self._maid:Add(Signal.new())
	self.playerRemoved = self._maid:Add(Signal.new())
end

function PlayersScoreServiceClient.Start(self)
	self._maid:Add(self._remoteEvent:Then(function(remoteEvent)
		self._maid:Add(remoteEvent.OnClientEvent:Connect(function(data)
			if data.message == "init" then
				for _, player in data.players do
					self.playersScores[player] = ValueObject.new(0, "number")
					self.playerAdded:Fire(player)
				end
			elseif data.message == "update" then
				self.playersScores[data.player]:SetValue(data.score)
			end
		end))
		self._maid:Add(self._activePlayersServiceClient.activePlayers.ItemRemoved:Connect(function(player)
			self.playersScores[player]:Destroy()
			self.playersScores[player] = nil
			self.playerRemoved:Fire(player)
		end))
		self._maid:Add(self._roundControllerServiceClient.newRoundSignal:Connect(function()
			for _, score in self.playersScores do
				score:SetValue(0)
			end
		end))
	end))
end

function PlayersScoreServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

return PlayersScoreServiceClient
