local require = require(script.Parent.loader).load(script)

local ActivePlayersService = {}
ActivePlayersService.ServiceName = "ActivePlayersService"

local Players = game:GetService("Players")

local PlayerClass = require("PlayerClass")
local Maid = require("Maid")
local GetRemoteEvent = require("GetRemoteEvent")
local Table = require("Table")
local Signal = require("Signal")

local REMOTE_EVENT_NAME = "ActivePlayers"

function ActivePlayersService.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._serviceBag = serviceBag
	self._remoteEvent = GetRemoteEvent(REMOTE_EVENT_NAME)

	-- Public
	self.activePlayers = {}
	self.playerAdded = self._maid:Add(Signal.new())
	self.playerRemoved = self._maid:Add(Signal.new())
end

function ActivePlayersService.Start(self)
	self._maid:Add(Players.PlayerAdded:Connect(function(player: Player)
		local playerObject = PlayerClass.new(self._serviceBag, player)

		-- Pass new player all the active players
		self._remoteEvent:FireClient(player, "init", Table.keys(self.activePlayers))

		self.activePlayers[player] = playerObject
		self.playerAdded:Fire(player)

		-- Pass other players the newly added player
		for _, otherPlayer in Players:GetPlayers() do
			if otherPlayer == player then
				continue
			end
			self._remoteEvent:FireClient(otherPlayer, "add", { player })
		end
	end))

	self._maid:Add(Players.PlayerRemoving:Connect(function(player: Player)
		self.activePlayers[player] = nil
		self.playerRemoved:Fire(player)
		self._remoteEvent:FireAllClients("remove", { player })
	end))
end

function ActivePlayersService.Destroy(self)
	self._maid:DoCleaning()
end

return ActivePlayersService
