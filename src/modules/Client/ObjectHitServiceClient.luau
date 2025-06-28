local require = require(script.Parent.loader).load(script)

local ObjectHitServiceClient = {}
ObjectHitServiceClient.ServiceName = "ObjectHitServiceClient"

local Maid = require("Maid")

local ObjectHitParticlesClient = require("ObjectHitParticlesClient")

function ObjectHitServiceClient:Init(ServiceBag)
	self._maid = Maid.new()

	self._serviceBag = ServiceBag
	self._gunServiceClient = ServiceBag:GetService(require("GunServiceClient"))
end

function ObjectHitServiceClient:Start()
	self._maid:Add(self._gunServiceClient.objectHitSignal:Connect(function(data)
		ObjectHitParticlesClient.new(self._serviceBag, data)
	end))
end

function ObjectHitServiceClient:Destroy()
	self._maid:DoCleaning()
end

return ObjectHitServiceClient
