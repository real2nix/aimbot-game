local require = require(script.Parent.loader).load(script)

local HealthServiceClient = {}
HealthServiceClient.ServiceName = "HealthServiceClient"

local Players = game:GetService("Players")

local Maid = require("Maid")
local ValueObject = require("ValueObject")
local RxAttributeUtils = require("RxAttributeUtils")

function HealthServiceClient.Init(self, serviceBag)
	self._maid = Maid.new()

	self._screenGuiProvider = serviceBag:GetService(require("ScreenGuiProvider"))
	self._deathServiceClient = serviceBag:GetService(require("DeathServiceClient"))

	self.health = ValueObject.new(150, "number")
end

function HealthServiceClient.Start(self)
	self._maid:Add(RxAttributeUtils.observeAttribute(Players.LocalPlayer, "health"):Subscribe(function(newValue: number)
		if newValue == 0 then
			self._deathServiceClient.clientDiedSignal:Fire()
		end
		self.health:SetValue(newValue)
	end))
end

function HealthServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

return HealthServiceClient
