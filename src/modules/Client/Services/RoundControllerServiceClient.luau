local require = require(script.Parent.loader).load(script)

local RoundControllerServiceClient = {}
RoundControllerServiceClient.ServiceName = "RoundControllerServiceClient"

local Maid = require("Maid")
local Signal = require("Signal")
local PromiseGetRemoteEvent = require("PromiseGetRemoteEvent")

local REMOTE_EVENT_NAME = "RoundControllerService"

function RoundControllerServiceClient.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._remoteEventPromise = PromiseGetRemoteEvent(REMOTE_EVENT_NAME)

	-- Public
	self.newRoundSignal = self._maid:Add(Signal.new())
	self.midRoundSignal = self._maid:Add(Signal.new())
	self.serverMessage = self._maid:Add(Signal.new())
end

function RoundControllerServiceClient.Start(self)
	self._maid:Add(self._remoteEventPromise:Then(function(remoteEvent)
		self._maid:Add(remoteEvent.OnClientEvent:Connect(function(data)
			if data.message == "newRound" then
				self.newRoundSignal:Fire(data)
			elseif data.message == "midRound" then
				self.midRoundSignal:Fire(data)
			end
		end))

		remoteEvent:FireServer({
			message = "init",
		})
	end))
end

function RoundControllerServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

return RoundControllerServiceClient
