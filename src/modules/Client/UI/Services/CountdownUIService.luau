local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local require = require(script.Parent.loader).load(script)

local CountdownServiceUI = {}
CountdownServiceUI.ServiceName = "CountdownServiceUI"

local Maid = require("Maid")

local function component(props)
	local timeLeft, setTimeLeft = React.useState(0)
	local roundSeconds, setRoundSeconds = React.useState(props._countdownServiceClient.roundSeconds.Value)

	React.useEffect(function()
		local maid = Maid.new()
		maid:Add(props._countdownServiceClient.roundSeconds.Changed:Connect(function(newValue)
			setRoundSeconds(newValue)
		end))
		return function()
			maid:DoCleaning()
		end
	end, {})

	React.useEffect(function()
		local countdownConnection: RBXScriptConnection? = nil
		local maid = Maid.new()

		local function startCountdown(roundStartTime)
			if countdownConnection then
				countdownConnection:Disconnect()
			end
			if roundStartTime == 0 then
				return
			end
			countdownConnection = RunService.Heartbeat:Connect(function()
				local newTimeLeft = math.max(0, (roundStartTime + roundSeconds) - os.time())
				setTimeLeft(newTimeLeft)
			end)
		end

		-- Start countdown immediately if roundStartTime is already set
		local currentRoundStartTime = props._countdownServiceClient.roundStartTime.Value
		if currentRoundStartTime and currentRoundStartTime > 0 then
			startCountdown(currentRoundStartTime)
		end

		-- Listen for changes to roundStartTime
		maid:Add(props._countdownServiceClient.roundStartTime.Changed:Connect(startCountdown))

		return function()
			maid:DoCleaning()
			if countdownConnection then
				countdownConnection:Disconnect()
			end
		end
	end, { roundSeconds })

	-- Format the time display, handle negative values
	local displayTime = math.max(0, timeLeft)
	local minutes = math.floor(displayTime / 60)
	local seconds = displayTime % 60

	return React.createElement("TextLabel", {
		Text = string.format("%d:%02d", minutes, seconds),
		Size = UDim2.fromScale(1, 0.05),
		Position = UDim2.new(0, 0, 0.08, 10),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
	})
end

function CountdownServiceUI.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._screenGuiProvider = serviceBag:GetService(require("ScreenGuiProvider"))
	self._countdownServiceClient = serviceBag:GetService(require("CountdownServiceClient"))
	self._root = nil
end

function CountdownServiceUI.Start(self)
	local handle = self._screenGuiProvider:Get("COUNTDOWN")
	handle.IgnoreGuiInset = true
	self._root = ReactRoblox.createRoot(handle)
	self._root:render(React.createElement(component, {
		_countdownServiceClient = self._countdownServiceClient,
	}))
end

function CountdownServiceUI.Destroy(self)
	self._maid:DoCleaning()
end

return CountdownServiceUI
