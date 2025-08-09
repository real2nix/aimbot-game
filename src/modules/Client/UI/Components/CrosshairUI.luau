local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local React = require(ReplicatedStorage["react-lua"]["react"])
local ReactRoblox = require(ReplicatedStorage["react-lua"]["react-roblox"])

local require = require(script.Parent.loader).load(script)

local CrosshairUI = {}
CrosshairUI.ServiceName = "CrosshairUI"

local Maid = require("Maid")

local WIDTH: number = 2
local HEIGHT: number = 6

function CrosshairUI.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._screenGuiProvider = serviceBag:GetService(require("ScreenGuiProvider"))
	self._deathServiceClient = serviceBag:GetService(require("DeathServiceClient"))
	self._root = nil
end

local function crosshair(props): ()
	local isDead, updateIsDead = React.useState(props._deathServiceClient.isClientDead.Value)
	props._deathServiceClient.isClientDead.Changed:Connect(function(newValue)
		updateIsDead(newValue)
	end)
	if isDead then
		return nil
	end
	return React.createElement("Frame", {
		Size = UDim2.fromOffset(20, 20),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
	}, {
		TopFrame = React.createElement("Frame", {
			Size = UDim2.fromOffset(WIDTH, HEIGHT),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
		}),
		BottomFrame = React.createElement("Frame", {
			Size = UDim2.fromOffset(WIDTH, HEIGHT),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
		}),

		LeftFrame = React.createElement("Frame", {
			Size = UDim2.fromOffset(HEIGHT, WIDTH),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
		}),
		RightFrame = React.createElement("Frame", {
			Size = UDim2.fromOffset(HEIGHT, WIDTH),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
		}),
	})
end

function CrosshairUI.Start(self)
	UserInputService.MouseIconEnabled = false

	local handle = self._screenGuiProvider:Get("CROSSHAIR")
	handle.IgnoreGuiInset = true
	self._root = ReactRoblox.createRoot(handle)
	self._root:render(React.createElement(crosshair, { _deathServiceClient = self._deathServiceClient }))
end

function CrosshairUI.Destroy(self)
	self._maid:DoCleaning()
end

return CrosshairUI
