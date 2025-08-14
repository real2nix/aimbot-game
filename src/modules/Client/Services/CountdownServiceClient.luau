local require = require(script.Parent.loader).load(script)

local CountdownServiceClient = {}
CountdownServiceClient.ServiceName = "CountdownServiceClient"

local Maid = require("Maid")
local ValueObject = require("ValueObject")

function CountdownServiceClient.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._roundControllerServiceClient = serviceBag:GetService(require("RoundControllerServiceClient"))
	self._currentCountdownConnection = nil

	-- Public
	self.roundStartTime = self._maid:Add(ValueObject.new(0))
	self.roundSeconds = self._maid:Add(ValueObject.new(0))
end

function CountdownServiceClient.Start(self)
	self._maid:Add(self._roundControllerServiceClient.newRoundSignal:Connect(function(data)
		self.roundStartTime:SetValue(data.roundStartTime)
		self.roundSeconds:SetValue(data.roundSeconds)
	end))
	self._maid:Add(self._roundControllerServiceClient.midRoundSignal:Connect(function(data)
		self.roundStartTime:SetValue(data.roundStartTime)
		self.roundSeconds:SetValue(data.roundSeconds)
	end))
end

function CountdownServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

return CountdownServiceClient
