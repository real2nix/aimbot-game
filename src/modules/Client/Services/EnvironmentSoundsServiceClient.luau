local require = require(script.Parent.loader).load(script)

local EnvironmentSoundsServiceClient = {}
EnvironmentSoundsServiceClient.ServiceName = "EnvironmentSoundsServiceClient"

local Maid = require("Maid")
local PromiseGetRemoteEvent = require("PromiseGetRemoteEvent")

function EnvironmentSoundsServiceClient.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()

	--self._remoteEvent1 = PromiseGetRemoteEvent("test")
end

function EnvironmentSoundsServiceClient.Start(self)
	-- connect to remotes
	--[[self._remoteEvent1:Then(function()
		-- play sound
	end)]]
end

function EnvironmentSoundsServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

return EnvironmentSoundsServiceClient
