local require = require(script.Parent.loader).load(script)

local DamageDirectionIndicatorService = {}
DamageDirectionIndicatorService.ServiceName = "DamageDirectionIndicatorService"

local Maid = require("Maid")
local GetRemoteEvent = require("GetRemoteEvent")
local CharacterUtils = require("CharacterUtils")

local REMOTE_EVENT_NAME = "DAMAGE_INDICATOR"

function DamageDirectionIndicatorService:Init(ServiceBag)
	-- Private
	self._maid = Maid.new()
	self._serviceBag = ServiceBag
	self._gunService = ServiceBag:GetService(require("GunService"))
	self._remoteEvent = GetRemoteEvent(REMOTE_EVENT_NAME)
end

function DamageDirectionIndicatorService:Start()
	self._maid:Add(self._gunService.playerHitSignal:Connect(function(data)
		local shooterRootPart: Part? = CharacterUtils.getPlayerRootPart(data.playerShooter)
		if not shooterRootPart then
			return
		end
		self._remoteEvent:FireClient(data.playerHit, shooterRootPart.Position)
	end))
end

function DamageDirectionIndicatorService:Destroy()
	self._maid:DoCleaning()
end

return DamageDirectionIndicatorService
