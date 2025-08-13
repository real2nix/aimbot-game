local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local require = require(script.Parent.loader).load(script)

local CharacterUtils = require("CharacterUtils")
local AttributeUtils = require("AttributeUtils")

return function(props)
	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		Visible = props.onScreen,
		BorderSizePixel = 0,
		Size = (function()
			return UDim2.new(
				0,
				(Vector2.new(props.screenPoint.X, props.screenPoint.Y) - Vector2.new(
					workspace.CurrentCamera.ViewportSize.X / 2,
					workspace.CurrentCamera.ViewportSize.Y / 2
				)).Magnitude,
				0,
				1
			)
		end)(),
		Position = (function()
			return UDim2.fromOffset(
				(workspace.CurrentCamera.ViewportSize.X / 2 + props.screenPoint.X) / 2,
				(workspace.CurrentCamera.ViewportSize.Y / 2 + props.screenPoint.Y) / 2
			)
		end)(),
		Rotation = (function()
			local centerX: number = workspace.CurrentCamera.ViewportSize.X / 2
			local centerY: number = workspace.CurrentCamera.ViewportSize.Y / 2

			local dirX: number = props.screenPoint.X - centerX
			local dirY: number = props.screenPoint.Y - centerY

			return math.deg(math.atan2(dirY, dirX))
		end)(),
	}, {})
end
