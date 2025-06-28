local require = require(script.Parent.loader).load(script)

local DeathServiceClient = {}
DeathServiceClient.ServiceName = "DeathServiceClient"

local Players = game:GetService("Players")

local Maid = require("Maid")
local Signal = require("Signal")
local Promise = require("Promise")

local REMOTE_EVENT_NAME: string = "PLAYER_KILLED"

function DeathServiceClient:Init(ServiceBag)
	-- Private
	self._maid = Maid.new()
	self._crosshairServiceClient = ServiceBag:GetService(require("CrosshairServiceClient"))

	-- Public
	self.clientDiedSignal = Signal.new()
end

function DeathServiceClient:Start()
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

function DeathServiceClient:Destroy()
	self._maid:DoCleaning()
end

return DeathServiceClient
