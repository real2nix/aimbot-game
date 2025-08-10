local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactSpring = require(ReplicatedStorage.Packages.ReactSpring)

local require = require(script.Parent.loader).load(script)

local Promise = require("Promise")

return function(props)
	local styles, api = ReactSpring.useSpring(function()
		return { transparency = 0.1 }
	end)

	React.useEffect(function()
		Promise.delay(2, function()
			api.start({ transparency = 1 }):andThen(function()
				props.onDestroy(props.id)
			end)
		end)
	end, {})

	return React.createElement("TextLabel", {
		Text = `<font color="#EE0000">Eliminated</font> <font color="#FFFFFF">{props.playerName}</font>`,
		Size = UDim2.fromScale(1, 0.1),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		RichText = true,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		TextTransparency = styles.transparency,
		TextStrokeTransparency = 1,
	}, {
		React.createElement("UIStroke", {
			Thickness = 1.5,
			Transparency = styles.transparency:map(function(value)
				return math.min(0.7 + value, 1)
			end),
		}),
	})
end
