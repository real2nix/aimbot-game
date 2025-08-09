local require = require(script.Parent.loader).load(script)

local GunService = {}
GunService.ServiceName = "GunService"

local Maid = require("Maid")
local CharacterUtils = require("CharacterUtils")
local PromiseGetRemoteEvent = require("PromiseGetRemoteEvent")
local Signal = require("Signal")

local REMOTE_EVENT_NAME: string = "GunController"

function GunService.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._activePlayersService = serviceBag:GetService(require("ActivePlayersService"))
	self._remoteEventPromise = PromiseGetRemoteEvent(REMOTE_EVENT_NAME)

	-- Public
	self.playerHitSignal = self._maid:Add(Signal.new())
end

function GunService.Start(self)
	self._remoteEventPromise:Then(function(remoteEvent: RemoteEvent)
		self._maid:Add(remoteEvent.OnServerEvent:Connect(function(player: Player, message: string, data)
			if message == "shoot" then
				-- Hit player has forcefield
				if self._activePlayersService.activePlayers[data.playerHit].forcefield then
					return
				end
				local playerHitRoot: Part? = CharacterUtils.getPlayerRootPart(data.playerHit)
				if not playerHitRoot then
					return
				end
				-- Verify shot
				if (playerHitRoot.Position - data.position).Magnitude > 20 then
					return
				end
				local damage = 20
				local playerHitHealth = self._activePlayersService.activePlayers[data.playerHit].health
				playerHitHealth.Value = math.max(playerHitHealth.Value - damage, 0)
				self.playerHitSignal:Fire(data)
			end
		end))
	end)
end

function GunService.Destroy(self)
	self._maid:DoCleaning()
end

return GunService
