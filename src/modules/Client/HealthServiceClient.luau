local require = require(script.Parent.loader).load(script)

local HealthServiceClient = {}
HealthServiceClient.ServiceName = "HealthServiceClient"

local Players = game:GetService("Players")

local Maid = require("Maid")
local Blend = require("Blend")
local ValueObject = require("ValueObject")
local Promise = require("Promise")
local RxAttributeUtils = require("RxAttributeUtils")
local CharacterUtils = require("CharacterUtils")

local Camera = workspace.CurrentCamera

function HealthServiceClient:Init(ServiceBag)
	self._maid = Maid.new()

	self._screenGuiProvider = ServiceBag:GetService(require("ScreenGuiProvider"))
	self._crosshairServiceClient = ServiceBag:GetService(require("CrosshairServiceClient"))
	self._deathServiceClient = ServiceBag:GetService(require("DeathServiceClient"))

	self.health = ValueObject.new(150, "number")
end

function HealthServiceClient:Start()
	self._maid:Add(RxAttributeUtils.observeAttribute(Players.LocalPlayer, "health"):Subscribe(function(newValue: number)
		if newValue == 0 then
			self._deathServiceClient.clientDiedSignal:Fire()
		end
		self.health:SetValue(newValue)
	end))

	self._maid:Add(Blend.New("Frame")({
		Size = UDim2.new(0.5, 0, 0, 15),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -15),
		Parent = self._screenGuiProvider:Get("HEALTH"),

		Blend.New("UICorner")({}),
		Blend.New("Frame")({
			Size = UDim2.new(1, -4, 1, -4),
			BackgroundColor3 = Color3.fromRGB(84, 255, 10),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Blend.New("UICorner")({}),

			Blend.New("TextLabel")({
				Text = Blend.Computed(self.health, function(val)
					return val .. " / 150"
				end),
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, 0, 1, -2),
				Size = UDim2.new(1, 0, 1, -5),
				TextXAlignment = Enum.TextXAlignment.Right,
				Font = Enum.Font.FredokaOne,
				BackgroundTransparency = 1,
			}),
		}),
	}):Subscribe())
end

function HealthServiceClient:Destroy()
	self._maid:DoCleaning()
end

return HealthServiceClient
