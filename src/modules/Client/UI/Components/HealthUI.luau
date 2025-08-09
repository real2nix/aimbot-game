local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage["react-lua"]["react"])
local ReactRoblox = require(ReplicatedStorage["react-lua"]["react-roblox"])

local require = require(script.Parent.loader).load(script)

local HealthUI = {}
HealthUI.ServiceName = "HealthUI"

local Maid = require("Maid")
local LuvColor3Utils = require("LuvColor3Utils")

function HealthUI.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._screenGuiProvider = serviceBag:GetService(require("ScreenGuiProvider"))
	self._healthServiceClient = serviceBag:GetService(require("HealthServiceClient"))
	self._root = nil
end

local function healthBar(props)
	local health, setHealth = React.useState(props.healthServiceClient.health.Value)
	React.useEffect(function()
		local connection = props.healthServiceClient.health.Changed:Connect(function(value)
			setHealth(value)
		end)
		return function()
			connection:Disconnect()
		end
	end, {})
	return React.createElement("Frame", {
		Size = UDim2.fromScale(health / 150, 1),
		BackgroundColor3 = LuvColor3Utils.lerp(
			Color3.fromRGB(67, 255, 46),
			Color3.fromRGB(255, 54, 54),
			(150 - health) / 150
		),
		BorderSizePixel = 0,
	}, { React.createElement("UICorner") })
end

local function backboard(props)
	return React.createElement("Frame", {
		Size = UDim2.fromScale(0.5, 0.02),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -15),
		BackgroundColor3 = Color3.fromRGB(94, 94, 94),
		BorderSizePixel = 0,
	}, { healthBar(props), React.createElement("UICorner") })
end

function HealthUI.Start(self)
	local handle = self._screenGuiProvider:Get("HEALTH")
	handle.IgnoreGuiInset = true
	self._root = ReactRoblox.createRoot(handle)
	self._root:render(React.createElement(backboard, { healthServiceClient = self._healthServiceClient }))
end

function HealthUI.Destroy(self)
	self._maid:DoCleaning()
end

return HealthUI
