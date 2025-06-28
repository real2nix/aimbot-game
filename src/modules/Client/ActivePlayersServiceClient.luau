local require = require(script.Parent.loader).load(script)

local ActivePlayersServiceClient = {}
ActivePlayersServiceClient.ServiceName = "ActivePlayersServiceClient"

local REMOTE_EVENT_NAME = "ActivePlayers"

local PromiseGetRemoteEvent = require("PromiseGetRemoteEvent")
local ObservableSet = require("ObservableSet")
local Maid = require("Maid")
local PlayerClassClient = require("PlayerClassClient")

function ActivePlayersServiceClient:Init(ServiceBag)
	self._maid = Maid.new()

	self._serviceBag = ServiceBag
	self._remoteEvent = PromiseGetRemoteEvent(REMOTE_EVENT_NAME)

	self.activePlayers = ObservableSet.new()
	self.playerObjects = {}
end

function ActivePlayersServiceClient:Start()
	self._maid:Add(self._remoteEvent:Then(function(remote)
		self._maid:Add(remote.OnClientEvent:Connect(function(message: string, players)
			if message == "init" then
				for _, player in players do
					self.activePlayers:Add(player)
				end
			elseif message == "add" then
				self.activePlayers:Add(players[1])
			elseif message == "remove" then
				self.activePlayers:Remove(players[1])
			end
		end))
	end))

	self._maid:Add(self.activePlayers.ItemAdded:Connect(function(player)
		self.playerObjects[player] = PlayerClassClient.new(self._serviceBag, player)
		self._maid[player] = self.playerObjects[player]
	end))
	self._maid:Add(self.activePlayers.ItemRemoved:Connect(function(player)
		self._maid[player] = nil
	end))
end

function ActivePlayersServiceClient:Destroy()
	self._maid:DoCleaning()
end

return ActivePlayersServiceClient
