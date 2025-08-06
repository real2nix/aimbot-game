local require = require(script.Parent.loader).load(script)

local HitmarkerServiceClient = {}
HitmarkerServiceClient.ServiceName = "HitmarkerServiceClient"

local _ServiceBag = require("ServiceBag")
local ClientTypes = require("ClientTypes")
local Maid = require("Maid")
local HitmarkerUIClient = require("HitmarkerUIClient")

function HitmarkerServiceClient.Init(self: ClientTypes.HitmarkerServiceClient, serviceBag: _ServiceBag.ServiceBag)
	self._maid = Maid.new()

	self._serviceBag = serviceBag
	self._gunServiceClient = serviceBag:GetService(require("GunServiceClient"))
end

function HitmarkerServiceClient.Start(self: ClientTypes.HitmarkerServiceClient)
	self._maid:Add(self._gunServiceClient.playerHitSignal:Connect(function()
		HitmarkerUIClient.new(self._serviceBag)
	end))
end

function HitmarkerServiceClient.Destroy(self: ClientTypes.HitmarkerServiceClient)
	self._maid:DoCleaning()
end

return HitmarkerServiceClient
