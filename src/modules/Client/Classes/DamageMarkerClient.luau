local require = require(script.Parent.loader).load(script)

local DamageMarkerClient = {}
DamageMarkerClient.ClassName = "DamageUIClient"
DamageMarkerClient.__index = DamageMarkerClient

local _ServiceBag = require("ServiceBag")
local ClientTypes = require("ClientTypes")
local Maid = require("Maid")
local Blend = require("Blend")
local SpringObject = require("SpringObject")
local Promise = require("Promise")

function DamageMarkerClient.new(serviceBag: _ServiceBag.ServiceBag, data): ClientTypes.DamageMarkerClient
	local self = setmetatable({}, DamageMarkerClient)

	self._maid = Maid.new()
	self._gunServiceClient = serviceBag:GetService(require("GunServiceClient"))
	self._highlightServiceClient = serviceBag:GetService(require("HighlightServiceClient"))

	local transparencySpring = self._maid:Add(SpringObject.new(1, 10, 2))
	transparencySpring:SetPosition(0)
	transparencySpring:Observe():Subscribe(function(value)
		if value >= 1 then
			self:Destroy()
		end
	end)

	self._maid:Add(Blend.New("Part")({
		Size = Vector3.new(),
		Position = data.position
			+ CFrame.fromAxisAngle(data.bulletUnitVector, math.random() * 2 * math.pi).RightVector
				* (data.distance / 100 + math.random(10, 35) / 10),
		Anchored = true,
		CanCollide = false,
		Parent = workspace,
		Name = "DamageMarker",
		Blend.New("BillboardGui")({
			Size = UDim2.new(0, 25, 0, 25),
			AlwaysOnTop = true,
			Blend.New("TextLabel")({
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Text = self._gunServiceClient.damagePerBullet.Value,
				TextScaled = true,
				Font = Enum.Font.GothamBold,
				TextColor3 = Color3.fromRGB(255, 55, 55),
				TextTransparency = transparencySpring:Observe(),
				Blend.New("UIStroke")({
					Thickness = 3,
					Color = Color3.fromRGB(126, 31, 31),
					Transparency = transparencySpring:Observe(),
				}),
			}),
		}),
	}):Subscribe())

	self._animatedHighlightModel = self._highlightServiceClient:Highlight(data.playerHit.Character, 2)
	self._animatedHighlightModel:SetHighlightDepthMode(Enum.HighlightDepthMode.AlwaysOnTop)
	self._animatedHighlightModel:SetSpeed(2.5)
	self._animatedHighlightModel:SetFillTransparency(0)
	self._animatedHighlightModel:SetFillColor(Color3.fromRGB(255, 255, 255))
	self._animatedHighlightModel:SetOutlineTransparency(1)

	Promise.delay(0.05, function()
		self._animatedHighlightModel:SetFillTransparency(1)
		Promise.delay(0.05, function()
			self._animatedHighlightModel:Destroy()
		end)
	end)

	return self
end

function DamageMarkerClient.Destroy(self: ClientTypes.DamageMarkerClient)
	self._maid:DoCleaning()
end

return DamageMarkerClient
