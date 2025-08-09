local require = require(script.Parent.loader).load(script)

local HitmarkerUIClient = {}
HitmarkerUIClient.ClassName = "HitmarkerUIClient"
HitmarkerUIClient.__index = HitmarkerUIClient

local ScreenGuiProvider = require("ScreenGuiProvider")
local Maid = require("Maid")
local Blend = require("Blend")
local SpringObject = require("SpringObject")
local Rx = require("Rx")

local WIDTH: number = 2
local HEIGHT: number = 10

function HitmarkerUIClient.new(serviceBag): ClientTypes.HitmarkerUIClient
	local self = setmetatable({}, HitmarkerUIClient)

	self._maid = Maid.new()
	self._screenGuiProvider = serviceBag:GetService(ScreenGuiProvider)

	local screenGui: ScreenGui = self._maid:Add(self._screenGuiProvider:Get("HITMARKER"))
	screenGui.IgnoreGuiInset = true

	local transparencySpring = SpringObject.new(1, 15, 1)
	transparencySpring:SetPosition(0)
	transparencySpring:Observe():Subscribe(function(value)
		if value >= 1 then
			self:Destroy()
		end
	end)

	local scaleSpring = SpringObject.new(0, 15, 1)
	scaleSpring:SetPosition(15)

	self._maid:Add(Blend.New("Frame")({
		Name = "Hitmarker",
		Size = scaleSpring:Observe():Pipe({
			Rx.map(function(value)
				return UDim2.new(0, 25 + value, 0, 25 + value)
			end),
		}),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = screenGui,
		Rotation = 45,
		Blend.New("Frame")({
			Name = "TopFrame",
			Size = UDim2.new(0, WIDTH, 0, HEIGHT),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			BackgroundTransparency = transparencySpring:Observe(),
			BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		}),
		Blend.New("Frame")({
			Name = "BottomFrame",
			Size = UDim2.new(0, WIDTH, 0, HEIGHT),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			BackgroundTransparency = transparencySpring:Observe(),
			BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		}),
		Blend.New("Frame")({
			Name = "LeftFrame",
			Size = UDim2.new(0, HEIGHT, 0, WIDTH),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			BackgroundTransparency = transparencySpring:Observe(),
			BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		}),
		Blend.New("Frame")({
			Name = "RightFrame",
			Size = UDim2.new(0, HEIGHT, 0, WIDTH),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(1, 0.5),
			BackgroundTransparency = transparencySpring:Observe(),
			BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		}),
	}):Subscribe())

	return self
end

function HitmarkerUIClient.Destroy(self: ClientTypes.HitmarkerUIClient)
	self._maid:DoCleaning()
end

return HitmarkerUIClient
