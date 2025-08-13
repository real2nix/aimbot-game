local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local require = require(script.Parent.loader).load(script)

local CountdownServiceUI = {}
CountdownServiceUI.ServiceName = "CountdownServiceUI"

local Maid = require("Maid")

local ROUND_SECONDS = 4 * 60

local function component(props)
	local timeLeft, setTimeLeft = React.useState(0)

	React.useEffect(function()
		local countdownConnection: RBXScriptConnection? = nil
		local roundStartTimeConnection = props._countdownServiceClient.roundStartTime.Changed:Connect(
			function(roundStartTime)
				if roundStartTime == 0 then
					return
				end
				if countdownConnection then
					countdownConnection:Disconnect()
				end
				countdownConnection = RunService.Heartbeat:Connect(function()
					local newTimeLeft = (roundStartTime + ROUND_SECONDS) - os.time()
					if newTimeLeft ~= timeLeft then
						setTimeLeft(newTimeLeft)
					end
				end)
			end
		)
		return function()
			roundStartTimeConnection:Disconnect()
			if countdownConnection then
				countdownConnection:Disconnect()
			end
		end
	end, {})

	return React.createElement("TextLabel", {
		Text = string.format("%d:%02d", timeLeft // 60, timeLeft % 60),
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
