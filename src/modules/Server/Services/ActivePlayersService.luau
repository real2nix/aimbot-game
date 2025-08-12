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

--[[
TODO

player must send signal to server that player is ready, dont rely on playeradded for the activeplayers
]]

function ActivePlayersService.Start(self)
	self._maid:Add(Players.PlayerAdded:Connect(function(player: Player)
		local playerObject = PlayerClass.new(self._serviceBag, player)
		self.activePlayers[player] = playerObject
	end))

	self._maid:Add(Players.PlayerRemoving:Connect(function(player: Player)
		self.activePlayers[player] = nil
		self.playerRemoved:Fire(player)
		self._remoteEvent:FireAllClients({
			message = "remove",
			player = player,
		})
	end))

	self._maid:Add(self._remoteEvent.OnServerEvent:Connect(function(player, data)
		if data.message == "ready" then
			-- Pass new player all the active players
			local allPlayers = Table.keys(self.activePlayers)
			local filteredPlayers = {}
			for _, p in allPlayers do
				if p ~= player then
					table.insert(filteredPlayers, p)
				end
			end
			self._remoteEvent:FireClient(player, {
				message = "init",
				players = filteredPlayers,
			})

			self.playerAdded:Fire(player)

			-- Pass other players the newly added player
			for _, otherPlayer in Players:GetPlayers() do
				if otherPlayer == player then
					continue
				end
				self._remoteEvent:FireClient(otherPlayer, {
					message = "add",
					player = player,
				})
			end
		end
	end))
end

function ActivePlayersService.Destroy(self)
	self._maid:DoCleaning()
end

return ActivePlayersService
