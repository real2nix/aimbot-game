local require = require(script.Parent.loader).load(script)

local PlayerHurtService = {}
PlayerHurtService.ServiceName = "PlayerHurtService"

local Maid = require("Maid")
local GetRemoteEvent = require("GetRemoteEvent")
local CharacterUtils = require("CharacterUtils")

local REMOTE_EVENT_NAME = "PlayerHurtService"

function PlayerHurtService.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._gunService = serviceBag:GetService(require("GunService"))
	self._remoteEvent = GetRemoteEvent(REMOTE_EVENT_NAME)

	-- Public
end

function PlayerHurtService.Start(self)
	self._maid:Add(self._gunService.playerHitSignal:Connect(function(data)
		local shooterRootPart: Part? = CharacterUtils.getPlayerRootPart(data.playerShooter)
		if not shooterRootPart then
			return
		end
		self._remoteEvent:FireClient(data.playerHit, {
			shooterPosition = shooterRootPart.Position,
		})
	end))
end

function PlayerHurtService.Destroy(self)
	self._maid:DoCleaning()
end

return PlayerHurtService
