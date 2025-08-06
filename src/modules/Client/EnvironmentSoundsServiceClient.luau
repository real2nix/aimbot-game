local require = require(script.Parent.loader).load(script)

local EnvironmentSoundsServiceClient = {}
EnvironmentSoundsServiceClient.ServiceName = "EnvironmentSoundsServiceClient"

local _ServiceBag = require("ServiceBag")
local ClientTypes = require("ClientTypes")
local Maid = require("Maid")
local PromiseGetRemoteEvent = require("PromiseGetRemoteEvent")

function EnvironmentSoundsServiceClient.Init(
	self: ClientTypes.EnvironmentSoundsServiceClient,
	serviceBag: _ServiceBag.ServiceBag
)
	-- Private
	self._maid = Maid.new()

	--self._remoteEvent1 = PromiseGetRemoteEvent("test")
end

function EnvironmentSoundsServiceClient.Start(self: ClientTypes.EnvironmentSoundsServiceClient)
	-- connect to remotes
	--[[self._remoteEvent1:Then(function()
		-- play sound
	end)]]
end

function EnvironmentSoundsServiceClient.Destroy(self: ClientTypes.EnvironmentSoundsServiceClient)
	self._maid:DoCleaning()
end

return EnvironmentSoundsServiceClient
