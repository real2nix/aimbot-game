local require = require(script.Parent.loader).load(script)

local SpawnPlayerService = {}
SpawnPlayerService.ServiceName = "SpawnPlayerService"

local Maid = require("Maid")
local Signal = require("Signal")
local Promise = require("Promise")

local FORCEFIELD_SECONDS: number = 2

function SpawnPlayerService.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._deathService = serviceBag:GetService(require("DeathService"))
	self._activePlayersService = serviceBag:GetService(require("ActivePlayersService"))
end

function SpawnPlayerService.Start(self)
	self._maid:Add(self._deathService.playerDiedSignal:Connect(function(player)
		Promise.delay(5, function()
			self:_addForcefield(player)
		end)
	end))

	self._maid:Add(self._activePlayersService.playerAdded:Connect(function(player)
		self:_addForcefield(player)
	end))
end

function SpawnPlayerService.Destroy(self)
	self._maid:DoCleaning()
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
