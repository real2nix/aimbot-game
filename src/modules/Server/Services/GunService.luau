local require = require(script.Parent.loader).load(script)

local GunService = {}
GunService.ServiceName = "GunService"

local Maid = require("Maid")
local CharacterUtils = require("CharacterUtils")
local PromiseGetRemoteEvent = require("PromiseGetRemoteEvent")
local Signal = require("Signal")

local REMOTE_EVENT_NAME: string = "GunController"
local DAMAGE = 20

function GunService.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._activePlayersService = serviceBag:GetService(require("ActivePlayersService"))
	self._remoteEventPromise = PromiseGetRemoteEvent(REMOTE_EVENT_NAME)

	-- Public
	self.playerHitSignal = self._maid:Add(Signal.new())
	self.playerDiedSignal = self._maid:Add(Signal.new())
end

function GunService.Start(self)
	self._remoteEventPromise:Then(function(remoteEvent: RemoteEvent)
		self._maid:Add(remoteEvent.OnServerEvent:Connect(function(player: Player, message: string, data)
			if message == "shoot" then
				if self._activePlayersService.activePlayers[data.playerHit].forcefield then
					-- Player has forcefield
					return
				end
				local playerHitRoot: Part? = CharacterUtils.getPlayerRootPart(data.playerHit)
				if not playerHitRoot then
					return
				end
				if (playerHitRoot.Position - data.position).Magnitude > 20 then
					-- False data, hacker?
					return
				end
				local playerHitHealth = self._activePlayersService.activePlayers[data.playerHit].health.Value
				if playerHitHealth <= 0 then
					-- Player already dead
					return
				end
				local playerNewHitHealth = math.max(playerHitHealth - DAMAGE, 0)
				self._activePlayersService.activePlayers[data.playerHit].health.Value = playerNewHitHealth

				self.playerHitSignal:Fire(data)

				if playerNewHitHealth == 0 then
					self.playerDiedSignal:Fire(data)
				end
			end
		end))
	end)
end

function GunService.Destroy(self)
	self._maid:DoCleaning()
end

return GunService
