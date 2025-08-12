local require = require(script.Parent.loader).load(script)

local RoundControllerService = {}
RoundControllerService.ServiceName = "RoundControllerService"

local RunService = game:GetService("RunService")

local Maid = require("Maid")
local Signal = require("Signal")
local GetRemoteEvent = require("GetRemoteEvent")

local REMOTE_EVENT_NAME = "RoundControllerService"

function RoundControllerService.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._remoteEvent = GetRemoteEvent(REMOTE_EVENT_NAME)

	-- Public
	self.startRound = self._maid:Add(Signal.new())
	self.endRound = self._maid:Add(Signal.new())
	self.roundStartTime = os.time()
	self.roundSeconds = 4 * 60
end

function RoundControllerService.Start(self)
	self._maid:Add(self.startRound:Connect(function()
		self.roundStartTime = os.time()
		local connection: RBXScriptConnection
		connection = RunService.Heartbeat:Connect(function()
			if os.time() >= self.roundStartTime + self.roundSeconds then
				self.endRound:Fire()
				connection:Disconnect()
			end
		end)
	end))
	self._maid:Add(self.endRound:Connect(function()
		-- show stats, wait X seconds
		self.startRound:Fire()
	end))

	self._maid:Add(self._remoteEvent.OnServerEvent:Connect(function(player, data)
		if data.message == "init" then
			self._remoteEvent:FireClient(player, {
				message = "midRound",
				roundStartTime = self.roundStartTime,
				roundSeconds = self.roundSeconds,
			})
		end
	end))

	self.startRound:Fire()
end

function RoundControllerService.Destroy(self)
	self._maid:DoCleaning()
end

return RoundControllerService
