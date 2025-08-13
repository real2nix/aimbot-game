local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local require = require(script.Parent.loader).load(script)

local CharacterUtils = require("CharacterUtils")

local function getBoundingBoxSize(props)
	local rootPart = CharacterUtils.getPlayerRootPart(props.player)
	if not rootPart then
		return UDim2.new()
	end
	local character = props.player.Character
	if not character then
		return UDim2.new()
	end
	local characterSize = character:GetExtentsSize()
	local topOffset = rootPart.CFrame.UpVector * characterSize.Y / 2
	local bottomOffset = -rootPart.CFrame.UpVector * characterSize.Y / 2
	local frontOffset = rootPart.CFrame.LookVector * characterSize.Z / 2
	local backOffset = -rootPart.CFrame.LookVector * characterSize.Z / 2
	local rightOffset = rootPart.CFrame.RightVector * characterSize.X / 2
	local leftOffset = -rootPart.CFrame.RightVector * characterSize.X / 2

	local corners3D = {
		rootPart.Position + topOffset + leftOffset + backOffset,
		rootPart.Position + topOffset + rightOffset + backOffset,
		rootPart.Position + topOffset + leftOffset + frontOffset,
		rootPart.Position + topOffset + rightOffset + frontOffset,
		rootPart.Position + bottomOffset + leftOffset + backOffset,
		rootPart.Position + bottomOffset + rightOffset + backOffset,
		rootPart.Position + bottomOffset + leftOffset + frontOffset,
		rootPart.Position + bottomOffset + rightOffset + frontOffset,
	}

	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge
	for _, corner in corners3D do
		local vec2 = workspace.CurrentCamera:WorldToViewportPoint(corner)
		minX = math.min(minX, vec2.X)
		minY = math.min(minY, vec2.Y)
		maxX = math.max(maxX, vec2.X)
		maxY = math.max(maxY, vec2.Y)
	end

	return UDim2.fromOffset(maxX - minX, maxY - minY)
end

return function(props)
	local lineThickness, setLineThickness = React.useState(2)

	React.useEffect(function()
		if workspace.CurrentCamera.ViewportSize.X <= 500 then
			setLineThickness(1)
		else
			setLineThickness(2)
		end
	end, { workspace.CurrentCamera.ViewportSize })

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Visible = props.onScreen,
		Size = getBoundingBoxSize(props),
		Position = (function()
			return UDim2.fromOffset(props.screenPoint.X, props.screenPoint.Y)
		end)(),
	}, {
		-- Top
		React.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, lineThickness),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			BackgroundColor3 = Color3.fromRGB(255, 0, 0),
			BorderSizePixel = 0,
		}),
		-- Bottom
		React.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, lineThickness),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			BackgroundColor3 = Color3.fromRGB(255, 0, 0),
			BorderSizePixel = 0,
		}),
		-- Left
		React.createElement("Frame", {
			Size = UDim2.new(0, lineThickness, 1, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 0, 0),
			BorderSizePixel = 0,
		}),
		-- Right
		React.createElement("Frame", {
			Size = UDim2.new(0, lineThickness, 1, 0),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 0, 0),
			BorderSizePixel = 0,
		}),
	})
end
