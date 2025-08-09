local require = require(script.Parent.loader).load(script)

local HitmarkerServiceClient = {}
HitmarkerServiceClient.ServiceName = "HitmarkerServiceClient"

local Maid = require("Maid")
local HitmarkerUIClient = require("HitmarkerUIClient")

function HitmarkerServiceClient.Init(self, serviceBag)
	self._maid = Maid.new()

	self._serviceBag = serviceBag
	self._gunServiceClient = serviceBag:GetService(require("GunServiceClient"))
end

function HitmarkerServiceClient.Start(self)
	self._maid:Add(self._gunServiceClient.playerHitSignal:Connect(function()
		HitmarkerUIClient.new(self._serviceBag)
	end))
end

function HitmarkerServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

return HitmarkerServiceClient
