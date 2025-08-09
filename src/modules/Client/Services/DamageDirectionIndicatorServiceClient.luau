local require = require(script.Parent.loader).load(script)

local DamageDirectionIndicatorServiceClient = {}
DamageDirectionIndicatorServiceClient.ServiceName = "DamageDirectionIndicatorServiceClient"

local DamageDirectionIndicatorUIClient = require("DamageDirectionIndicatorUIClient")

local Maid = require("Maid")
local PromiseGetRemoteEvent = require("PromiseGetRemoteEvent")

local REMOTE_EVENT_NAME = "DAMAGE_INDICATOR"

function DamageDirectionIndicatorServiceClient.Init(self, serviceBag)
	self._maid = Maid.new()
	self._serviceBag = serviceBag
end

function DamageDirectionIndicatorServiceClient.Start(self)
	self._maid:Add(PromiseGetRemoteEvent(REMOTE_EVENT_NAME):Then(function(remoteEvent: RemoteEvent)
		self._maid:Add(remoteEvent.OnClientEvent:Connect(function(shooterPosition: Vector3)
			DamageDirectionIndicatorUIClient.new(self._serviceBag, shooterPosition)
		end))
	end))
end

function DamageDirectionIndicatorServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

return DamageDirectionIndicatorServiceClient
