local require = require(script.Parent.loader).load(script)

local ActivePlayersService = {}
ActivePlayersService.ServiceName = "ActivePlayersService"

local Players = game:GetService("Players")

local Maid = require("Maid")
local GetRemoteEvent = require("GetRemoteEvent")
local PlayerClass = require("PlayerClass")
local Table = require("Table")

local REMOTE_EVENT_NAME = "ActivePlayers"

function ActivePlayersService:Init(ServiceBag)
	-- Private
	self._maid = Maid.new()
	self._serviceBag = ServiceBag
	self._remoteEvent = GetRemoteEvent(REMOTE_EVENT_NAME)

	-- Public
	self.activePlayers = {}
end

function ActivePlayersService:Start()
	self._maid:Add(Players.PlayerAdded:Connect(function(playerAdded: Player)
		local playerObject = PlayerClass.new(self._serviceBag, playerAdded)

		-- Pass new player all the active players
		self._remoteEvent:FireClient(playerAdded, "init", Table.keys(self.activePlayers))

		-- Pass players the newly added player
		self.activePlayers[playerAdded] = playerObject
		for _, player in Players:GetPlayers() do
			if player == playerAdded then
				continue
			end
			self._remoteEvent:FireClient(player, "add", { playerAdded })
		end
	end))

	self._maid:Add(Players.PlayerRemoving:Connect(function(playerRemoved: Player)
		self.activePlayers[playerRemoved] = nil
		self._remoteEvent:FireAllClients("remove", { playerRemoved })
	end))
end

function ActivePlayersService:Destroy()
	self._maid:DoCleaning()
end

return ActivePlayersService
