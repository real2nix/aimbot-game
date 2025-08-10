local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local require = require(script.Parent.loader).load(script)

local ReloadUI = {}
ReloadUI.ServiceName = "ReloadUI"

local Maid = require("Maid")

local function ReloadCountdown(props)
	local gunServiceClient = props.gunServiceClient
	local timeRemaining, setTimeRemaining = React.useState(0)

	React.useEffect(function()
		local connection = gunServiceClient.reloadSignal:Connect(function()
			setTimeRemaining(gunServiceClient.reloadSeconds.Value)
		end)

		return function()
			connection:Disconnect()
		end
	end, { gunServiceClient })

	React.useEffect(function()
		if timeRemaining <= 0 then
			return
		end

		local connection = RunService.Heartbeat:Connect(function(deltaTime)
			setTimeRemaining(function(currentTime)
				local newTime = currentTime - deltaTime
				if newTime <= 0 then
					return 0
				end
				return newTime
			end)
		end)

		return function()
			connection:Disconnect()
		end
	end, { timeRemaining })

	if timeRemaining <= 0 then
		return nil
	end

	return React.createElement("TextLabel", {
		Size = UDim2.fromScale(1, 0.035),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.525, 0.525),
		BackgroundTransparency = 1,
		TextScaled = true,
		TextColor3 = Color3.new(1, 1, 1),
		Text = string.format("%.1f", timeRemaining),
		TextSize = 24,
		Font = Enum.Font.GothamBold,
		TextStrokeTransparency = 1,
	})
end

function ReloadUI.Init(self, serviceBag)
	self._maid = Maid.new()
	self._gunServiceClient = serviceBag:GetService(require("GunServiceClient"))
	self._screenGuiProvider = serviceBag:GetService(require("ScreenGuiProvider"))
	self._root = nil
end

function ReloadUI.Start(self)
	local handle = self._screenGuiProvider:Get("RELOAD")
	handle.IgnoreGuiInset = true
	self._root = ReactRoblox.createRoot(handle)
	self._root:render(React.createElement(ReloadCountdown, {
		gunServiceClient = self._gunServiceClient,
	}))
end

function ReloadUI.Destroy(self)
	if self._root then
		self._root:unmount()
		self._root = nil
	end
	self._maid:DoCleaning()
end

return ReloadUI
