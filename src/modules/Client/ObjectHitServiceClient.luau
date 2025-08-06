local require = require(script.Parent.loader).load(script)

local ObjectHitServiceClient = {}
ObjectHitServiceClient.ServiceName = "ObjectHitServiceClient"

local _ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local ClientTypes = require("ClientTypes")
local ObjectHitParticlesClient = require("ObjectHitParticlesClient")

function ObjectHitServiceClient.Init(self: ClientTypes.ObjectHitServiceClient, serviceBag: _ServiceBag.ServiceBag)
	self._maid = Maid.new()
	self._serviceBag = serviceBag
	self._gunServiceClient = serviceBag:GetService(require("GunServiceClient"))
end

function ObjectHitServiceClient.Start(self: ClientTypes.ObjectHitServiceClient)
	self._maid:Add(self._gunServiceClient.objectHitSignal:Connect(function(data)
		ObjectHitParticlesClient.new(self._serviceBag, data)
	end))
end

function ObjectHitServiceClient.Destroy(self: ClientTypes.ObjectHitServiceClient)
	self._maid:DoCleaning()
end

return ObjectHitServiceClient
