local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local React = require(ReplicatedStorage.Packages.React)

local DURATION = 0.3

return function(props)
	local timeRemaining, setTimeRemaining = React.useState(DURATION)
	local scale, setScale = React.useState(0)
	local alpha, setAlpha = React.useState(1)

	-- Animation and self-destruction timer
	React.useEffect(function()
		local startTime = os.clock()

		local connection = RunService.Heartbeat:Connect(function()
			local elapsed = os.clock() - startTime
			local progress = elapsed / DURATION
			setTimeRemaining(function()
				return DURATION - elapsed
			end)

			-- Scale animation: grow then shrink
			if progress < 0.2 then
				setScale(progress * 5) -- 0 to 1 in first 20%
			else
				setScale(1 + (progress - 0.2) * 0.5) -- 1 to 1.4 over remaining time
			end

			-- Fade out in last 60% of duration
			if progress > 0.4 then
				setAlpha((1 - progress) / 0.6)
			end

			-- Self-destruct when time is up
			if timeRemaining <= 0 then
				props.onDestroy(props.id)
			end
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	-- Don't render if expired
	if timeRemaining <= 0 then
		return nil
	end
	local size = 20

	return React.createElement("Frame", {
		Size = UDim2.fromOffset(size * scale, size * scale),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
	}, {
		Line1 = React.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1 - alpha,
			BorderSizePixel = 0,
			Rotation = 45,
		}),
		Line2 = React.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1 - alpha,
			BorderSizePixel = 0,
			Rotation = -45,
		}),
	})
end
