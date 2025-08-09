local require = require(script.Parent.loader).load(script)

local ObjectHitServiceClient = {}
ObjectHitServiceClient.ServiceName = "ObjectHitServiceClient"

local Maid = require("Maid")

local ObjectHitParticlesClient = require("ObjectHitParticlesClient")

function ObjectHitServiceClient.Init(self, serviceBag)
	self._maid = Maid.new()
	self._serviceBag = serviceBag
	self._gunServiceClient = serviceBag:GetService(require("GunServiceClient"))
end

function ObjectHitServiceClient.Start(self)
	self._maid:Add(self._gunServiceClient.objectHitSignal:Connect(function(data)
		ObjectHitParticlesClient.new(self._serviceBag, data)
	end))
end

function ObjectHitServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

return ObjectHitServiceClient
