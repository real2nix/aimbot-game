local Players = game:GetService("Players")

local require = require(script.Parent.loader).load(script)

local SpawnPlayerServiceClient = {}
SpawnPlayerServiceClient.ServiceName = "SpawnPlayerServiceClient"

local Maid = require("Maid")
local PromiseGetRemoteEvent = require("PromiseGetRemoteEvent")

local REMOTE_EVENT_NAME: string = "SpawnPlayerService"

function SpawnPlayerServiceClient.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._deathServiceClient = serviceBag:GetService(require("DeathServiceClient"))
	self._remoteEventPromise = PromiseGetRemoteEvent(REMOTE_EVENT_NAME)

	-- Public
end

function SpawnPlayerServiceClient.Start(self)
	self._maid:Add(self._remoteEventPromise:Then(function(remoteEvent)
		remoteEvent.OnClientEvent:Connect(function(data)
			if data.message == "spawn" then
				Players.LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
				self._deathServiceClient.isClientDead:SetValue(false)
			end
		end)
	end))
end

function SpawnPlayerServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

return SpawnPlayerServiceClient
