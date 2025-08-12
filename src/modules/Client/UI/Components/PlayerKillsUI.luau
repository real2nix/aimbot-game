local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local require = require(script.Parent.loader).load(script)

return function(props)
	-- connect to event, listen to see if it changes
	local kills, setKills = React.useState(props._playersScoreServiceClient.playerScores[props.player].Value)

	React.useEffect(function()
		local connection = props._playersScoreServiceClient.playerScores[props.player].Changed:Connect(function(value)
			setKills(value)
		end)
		return function()
			connection:Disconnect()
		end
	end, {})

	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
	}, {
		React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			TextScaled = true,
			Text = kills,
		}, {
			React.createElement("UIStroke", {
				Color = Color3.fromRGB(255, 255, 255),
				Thickness = 2,
			}),
		}),
	})
end
