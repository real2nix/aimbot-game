local require = require(script.Parent.loader).load(script)

local CrosshairServiceClient = {}
CrosshairServiceClient.ServiceName = "CrosshairServiceClient"

local UserInputService: UserInputService = game:GetService("UserInputService")

local _ServiceBag = require("ServiceBag")
local ClientTypes = require("ClientTypes")
local ScreenGuiProvider = require("ScreenGuiProvider")
local Maid = require("Maid")
local Blend = require("Blend")
local ValueObject = require("ValueObject")

local WIDTH: number = 2
local HEIGHT: number = 6

function CrosshairServiceClient.Init(self: ClientTypes.CrosshairServiceClient, ServiceBag: _ServiceBag.ServiceBag)
	-- Private
	self._maid = Maid.new()
	self._screenGuiProvider = ServiceBag:GetService(ScreenGuiProvider)

	-- Public
	self.crosshairEnabled = self._maid:Add(ValueObject.new(true, "boolean"))
end

function CrosshairServiceClient.Start(self: ClientTypes.CrosshairServiceClient)
	UserInputService.MouseIconEnabled = not self.crosshairEnabled:Observe()

	local screenGui: ScreenGui = self._screenGuiProvider:Get("CROSSHAIR")
	screenGui.IgnoreGuiInset = true

	self._maid:Add(Blend.New("Frame")({
		Name = "CrosshairFrameContainer",
		Size = UDim2.fromOffset(20, 20),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		Visible = self.crosshairEnabled:Observe(),
		Parent = screenGui,
		Blend.New("Frame")({
			Name = "TopFrame",
			Size = UDim2.new(0, WIDTH, 0, HEIGHT),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
		}),
		Blend.New("Frame")({
			Name = "BottomFrame",
			Size = UDim2.new(0, WIDTH, 0, HEIGHT),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
		}),
		Blend.New("Frame")({
			Name = "LeftFrame",
			Size = UDim2.new(0, HEIGHT, 0, WIDTH),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
		}),
		Blend.New("Frame")({
			Name = "RightFrame",
			Size = UDim2.new(0, HEIGHT, 0, WIDTH),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(1, 0.5),
		}),
	}):Subscribe())
end

function CrosshairServiceClient.Destroy(self: ClientTypes.CrosshairServiceClient)
	self._maid:DoCleaning()
end

return CrosshairServiceClient
