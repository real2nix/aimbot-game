local require = require(script.Parent.loader).load(script)

local DeathServiceClient = {}
DeathServiceClient.ServiceName = "DeathServiceClient"

local Players = game:GetService("Players")

local _ServiceBag = require("ServiceBag")
local ClientTypes = require("ClientTypes")
local CrosshairServiceClient = require("CrosshairServiceClient")
local Maid = require("Maid")
local Signal = require("Signal")
local Promise = require("Promise")

local REMOTE_EVENT_NAME: string = "PLAYER_KILLED"

function DeathServiceClient.Init(self: ClientTypes.DeathServiceClient, ServiceBag: _ServiceBag.ServiceBag)
	-- Private
	self._maid = Maid.new()
	self._crosshairServiceClient = ServiceBag:GetService(CrosshairServiceClient)

	-- Public
	self.clientDiedSignal = Signal.new()
end

function DeathServiceClient.Start(self: ClientTypes.DeathServiceClient)
	self._maid:Add(self.clientDiedSignal:Connect(function()
		self._crosshairServiceClient.crosshairEnabled:SetValue(false)
		Players.LocalPlayer.CameraMode = Enum.CameraMode.Classic
		Players.LocalPlayer.CameraMaxZoomDistance = 25
		Players.LocalPlayer.CameraMinZoomDistance = 25

		Promise.delay(5, function()
			Players.LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
			self._crosshairServiceClient.crosshairEnabled:SetValue(true)
		end)
	end))
end

function DeathServiceClient.Destroy(self: ClientTypes.DeathServiceClient)
	self._maid:DoCleaning()
end

return DeathServiceClient
