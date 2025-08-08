local require = require(script.Parent.loader).load(script)

local HealthServiceClient = {}
HealthServiceClient.ServiceName = "HealthServiceClient"

local Players = game:GetService("Players")

local _ServiceBag = require("ServiceBag")
local ClientTypes = require("ClientTypes")
local Maid = require("Maid")
local Blend = require("Blend")
local ValueObject = require("ValueObject")
local RxAttributeUtils = require("RxAttributeUtils")

function HealthServiceClient.Init(self: ClientTypes.HealthServiceClient, serviceBag: _ServiceBag.ServiceBag)
	self._maid = Maid.new()

	self._screenGuiProvider = serviceBag:GetService(require("ScreenGuiProvider"))
	self._crosshairServiceClient = serviceBag:GetService(require("CrosshairServiceClient"))
	self._deathServiceClient = serviceBag:GetService(require("DeathServiceClient"))

	self.health = ValueObject.new(150, "number")
end

function HealthServiceClient.Start(self: ClientTypes.HealthServiceClient)
	self._maid:Add(RxAttributeUtils.observeAttribute(Players.LocalPlayer, "health"):Subscribe(function(newValue: number)
		if newValue == 0 then
			self._deathServiceClient.clientDiedSignal:Fire()
		end
		self.health:SetValue(newValue)
	end))

	self._maid:Add(Blend.New("Frame")({
		Size = UDim2.fromScale(0.5, 0.02),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -15),
		BackgroundColor3 = Color3.fromRGB(94, 94, 94),
		Parent = self._screenGuiProvider:Get("HEALTH"),

		Blend.New("Frame")({
			Size = Blend.Computed(self.health, function(health: number)
				return UDim2.fromScale(health / 150, 1)
			end),
			BackgroundColor3 = Color3.fromRGB(84, 255, 10),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
		}),
	}):Subscribe())
end

function HealthServiceClient.Destroy(self: ClientTypes.HealthServiceClient)
	self._maid:DoCleaning()
end

return HealthServiceClient
