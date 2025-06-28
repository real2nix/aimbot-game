local require = require(script.Parent.loader).load(script)

local HitmarkerServiceClient = {}
HitmarkerServiceClient.ServiceName = "HitmarkerServiceClient"

local Maid = require("Maid")

local HitmarkerUIClient = require("HitmarkerUIClient")

function HitmarkerServiceClient:Init(ServiceBag)
	self._maid = Maid.new()

	self._serviceBag = ServiceBag
	self._gunServiceClient = ServiceBag:GetService(require("GunServiceClient"))
end

function HitmarkerServiceClient:Start()
	self._maid:Add(self._gunServiceClient.playerHitSignal:Connect(function()
		HitmarkerUIClient.new(self._serviceBag)
	end))
end

function HitmarkerServiceClient:Destroy()
	self._maid:DoCleaning()
end

return HitmarkerServiceClient
