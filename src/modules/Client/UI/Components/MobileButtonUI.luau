local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local require = require(script.Parent.loader).load(script)

return function(props)
	local isActive, setIsActive = React.useState(false)

	return React.createElement("TextButton", {
		Size = UDim2.fromOffset(65, 65),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Text = "",
		Position = props.position,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.5,
		[React.Event.MouseButton1Down] = function()
			if props.mouseButton1Down then
				props.mouseButton1Down()
			end
			setIsActive(true)
		end,
		[React.Event.MouseButton1Up] = function()
			if props.mouseButton1Up then
				props.mouseButton1Up()
			end
			setIsActive(false)
		end,
		[React.Event.MouseButton1Click] = props.mouseButton1Click,
	}, {
		React.createElement("ImageLabel", {
			Image = `rbxassetid://{props.imageId}`,
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0.6, 0.6),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
		}),
		React.createElement("UICorner", {
			CornerRadius = UDim.new(2, 0),
		}),
	})
end
