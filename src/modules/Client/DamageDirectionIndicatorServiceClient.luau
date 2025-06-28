local require = require(script.Parent.loader).load(script)

local DamageDirectionIndicatorServiceClient = {}
DamageDirectionIndicatorServiceClient.ServiceName = "DamageDirectionIndicatorServiceClient"

local DamageDirectionIndicatorUIClient = require("DamageDirectionIndicatorUIClient")

local Maid = require("Maid")
local PromiseGetRemoteEvent = require("PromiseGetRemoteEvent")

local REMOTE_EVENT_NAME: string = "DAMAGE_INDICATOR"

function DamageDirectionIndicatorServiceClient:Init(ServiceBag)
	-- Private
	self._maid = Maid.new()
	self._serviceBag = ServiceBag
end

function DamageDirectionIndicatorServiceClient:Start()
	self._maid:Add(PromiseGetRemoteEvent(REMOTE_EVENT_NAME):Then(function(remoteEvent: RemoteEvent)
		self._maid:Add(remoteEvent.OnClientEvent:Connect(function(shooterPosition: Vector3)
			DamageDirectionIndicatorUIClient.new(self._serviceBag, shooterPosition)
		end))
	end))
end

function DamageDirectionIndicatorServiceClient:Destroy()
	self._maid:DoCleaning()
end

return DamageDirectionIndicatorServiceClient
