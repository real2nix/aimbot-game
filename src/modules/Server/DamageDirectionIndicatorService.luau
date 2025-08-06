local require = require(script.Parent.loader).load(script)

local DamageDirectionIndicatorService = {}
DamageDirectionIndicatorService.ServiceName = "DamageDirectionIndicatorService"

local _ServiceBag = require("ServiceBag")
local ServerTypes = require("ServerTypes")
local Maid = require("Maid")
local Signal = require("Signal")
local GetRemoteEvent = require("GetRemoteEvent")
local CharacterUtils = require("CharacterUtils")

local REMOTE_EVENT_NAME = "DAMAGE_INDICATOR"

function DamageDirectionIndicatorService.Init(
	self: ServerTypes.DamageDirectionIndicatorService,
	serviceBag: _ServiceBag.ServiceBag
)
	-- Private
	self._maid = Maid.new()
	self._gunService = serviceBag:GetService(require("GunService"))
	self._remoteEvent = GetRemoteEvent(REMOTE_EVENT_NAME)
end

function DamageDirectionIndicatorService.Start(self: ServerTypes.DamageDirectionIndicatorService)
	self._maid:Add(self._gunService.playerHitSignal:Connect(function(data)
		local shooterRootPart: Part? = CharacterUtils.getPlayerRootPart(data.playerShooter)
		if not shooterRootPart then
			return
		end
		self._remoteEvent:FireClient(data.playerHit, shooterRootPart.Position)
	end))
end

function DamageDirectionIndicatorService.Destroy(self: ServerTypes.DamageDirectionIndicatorService)
	self._maid:DoCleaning()
end

return DamageDirectionIndicatorService
