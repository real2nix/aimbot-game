local require = require(script.Parent.loader).load(script)

local DeathServiceClient = {}
DeathServiceClient.ServiceName = "DeathServiceClient"

local Players = game:GetService("Players")

local Maid = require("Maid")
local Signal = require("Signal")
local Promise = require("Promise")
local ValueObject = require("ValueObject")

local REMOTE_EVENT_NAME = "PLAYER_KILLED"

function DeathServiceClient.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()

	-- Public
	self.clientDiedSignal = self._maid:Add(Signal.new())
	self.isClientDead = self._maid:Add(ValueObject.new(false, "boolean"))
end

function DeathServiceClient.Start(self)
	self._maid:Add(self.clientDiedSignal:Connect(function()
		self.isClientDead:SetValue(true)
		Players.LocalPlayer.CameraMode = Enum.CameraMode.Classic
		Players.LocalPlayer.CameraMaxZoomDistance = 25
		Players.LocalPlayer.CameraMinZoomDistance = 25

		Promise.delay(5, function()
			Players.LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
			self.isClientDead:SetValue(false)
		end)
	end))
end

function DeathServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

return DeathServiceClient
