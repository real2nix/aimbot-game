local require = require(script.Parent.loader).load(script)

local ActivePlayersServiceClient = {}
ActivePlayersServiceClient.ServiceName = "ActivePlayersServiceClient"

local PlayerClassClient = require("PlayerClassClient")
local PromiseGetRemoteEvent = require("PromiseGetRemoteEvent")
local ObservableSet = require("ObservableSet")
local Maid = require("Maid")

local REMOTE_EVENT_NAME = "ActivePlayers"

function ActivePlayersServiceClient.Init(self, serviceBag)
	self._maid = Maid.new()

	self._serviceBag = serviceBag
	self._remoteEventPromise = PromiseGetRemoteEvent(REMOTE_EVENT_NAME)

	self.activePlayers = ObservableSet.new()
	self.playerObjects = {}
end

function ActivePlayersServiceClient.Start(self)
	self._maid:Add(self._remoteEventPromise:Then(function(remote: RemoteEvent)
		self._maid:Add(remote.OnClientEvent:Connect(function(data)
			if data.message == "init" then
				for _, player in data.players do
					self.activePlayers:Add(player)
				end
			elseif data.message == "add" then
				self.activePlayers:Add(data.player)
			elseif data.message == "remove" then
				self.activePlayers:Remove(data.player)
			end
		end))
		remote:FireServer({
			message = "ready",
		})
	end))

	self._maid:Add(self.activePlayers.ItemAdded:Connect(function(player)
		self.playerObjects[player] = PlayerClassClient.new(self._serviceBag, player)
		self._maid[player] = self.playerObjects[player]
	end))
	self._maid:Add(self.activePlayers.ItemRemoved:Connect(function(player)
		self._maid[player] = nil
	end))
end

function ActivePlayersServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

return ActivePlayersServiceClient
