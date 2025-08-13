local require = require(script.Parent.loader).load(script)

local PlayerHurtServiceClient = {}
PlayerHurtServiceClient.ServiceName = "PlayerHurtServiceClient"

local Maid = require("Maid")
local Signal = require("Signal")
local PromiseGetRemoteEvent = require("PromiseGetRemoteEvent")

local REMOTE_EVENT_NAME = "PlayerHurtService"

function PlayerHurtServiceClient.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._remoteEventPromise = PromiseGetRemoteEvent(REMOTE_EVENT_NAME)

	-- Public
	self.playerHurtSignal = self._maid:Add(Signal.new())
end

function PlayerHurtServiceClient.Start(self)
	self._maid:Add(self._remoteEventPromise:Then(function(remoteEvent: RemoteEvent)
		self._maid:Add(remoteEvent.OnClientEvent:Connect(function(data)
			self.playerHurtSignal:Fire(data)
		end))
	end))
end

function PlayerHurtServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

return PlayerHurtServiceClient
