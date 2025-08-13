local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local require = require(script.Parent.loader).load(script)

local JumpButtonUtils = require("JumpButtonUtils")

return function(props)
	local isActive, setIsActive = React.useState(false)
	local buttonPosition, setButtonPosition = React.useState(UDim2.new(1, -90, 1, -90))
	local buttonSize, setButtonSize = React.useState(UDim2.new(1, -90, 1, -90))

	React.useEffect(function()
		local jumpButtonPosition, jumpButtonWidth =
			JumpButtonUtils.getJumpButtonPositionAndSize(workspace.CurrentCamera.ViewportSize)
		local newSize = UDim2.fromOffset(jumpButtonWidth, jumpButtonWidth)

		if props.sizeOffset then
			newSize = UDim2.fromOffset(jumpButtonWidth + props.sizeOffset, jumpButtonWidth + props.sizeOffset)
		end

		local newPosition
		local gap = 20 -- consistent gap between buttons

		if props.positioning == "above" then
			-- Position directly above the jump button
			newPosition = UDim2.new(
				jumpButtonPosition.X.Scale,
				jumpButtonPosition.X.Offset,
				jumpButtonPosition.Y.Scale,
				jumpButtonPosition.Y.Offset - newSize.Y.Offset - gap
			)
		elseif props.positioning == "left" then
			-- Position directly to the left of the jump button
			newPosition = UDim2.new(
				jumpButtonPosition.X.Scale,
				jumpButtonPosition.X.Offset - newSize.X.Offset - gap,
				jumpButtonPosition.Y.Scale,
				jumpButtonPosition.Y.Offset
			)
		else
			-- Default positioning (bottom-right of jump button)
			newPosition = UDim2.new(
				jumpButtonPosition.X.Scale,
				jumpButtonPosition.X.Offset - newSize.X.Offset,
				jumpButtonPosition.Y.Scale,
				jumpButtonPosition.Y.Offset - newSize.Y.Offset
			)
		end

		-- Apply any additional position offsets
		if props.positionOffset then
			newPosition = UDim2.new(
				newPosition.X.Scale,
				newPosition.X.Offset + props.positionOffset.X,
				newPosition.Y.Scale,
				newPosition.Y.Offset + props.positionOffset.Y
			)
		end

		setButtonSize(newSize)
		setButtonPosition(newPosition)
	end, { workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y })

	return React.createElement("TextButton", {
		Size = buttonSize,
		Text = "",
		Position = buttonPosition,
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
		[React.Event.MouseLeave] = props.mouseExit,
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
