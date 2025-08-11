local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local React = require(ReplicatedStorage.Packages.React)

local require = require(script.Parent.loader).load(script)

local CharacterUtils = require("CharacterUtils")
local AttributeUtils = require("AttributeUtils")

local function getBoundingBoxSize(props)
	local rootPart = CharacterUtils.getPlayerRootPart(props.player)
	if not rootPart then
		print("no rootpart")
		return UDim2.new()
	end
	local character = props.player.Character
	if not character then
		print("no chjaracter")
		return UDim2.new()
	end
	local topOffset = rootPart.CFrame.UpVector * props.characterSize.Y / 2
	local bottomOffset = -rootPart.CFrame.UpVector * props.characterSize.Y / 2
	local frontOffset = rootPart.CFrame.LookVector * props.characterSize.Z / 2
	local backOffset = -rootPart.CFrame.LookVector * props.characterSize.Z / 2
	local rightOffset = rootPart.CFrame.RightVector * props.characterSize.X / 2
	local leftOffset = -rootPart.CFrame.RightVector * props.characterSize.X / 2

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
	local screenData, setScreenData = React.useState({ screenPoint = Vector3.new(), onScreen = false })
	local lineThickness, setLineThickness = React.useState(2)

	React.useEffect(function()
		local connection = RunService.PreRender:Connect(function()
			local rootPart = CharacterUtils.getPlayerRootPart(props.player)
			if
				not rootPart
				or AttributeUtils.getAttribute(props.player, "health") <= 0
				or AttributeUtils.getAttribute(Players.LocalPlayer, "health") <= 0
			then
				setScreenData({
					screenPoint = Vector3.new(),
					onScreen = false,
				})
			end
			local screenPoint: Vector3, onScreen: boolean =
				workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
			if
				screenData.screenPoint.X ~= screenPoint.X
				or screenData.screenPoint.Y ~= screenPoint.Y
				or screenData.screenPoint.Z ~= screenPoint.Z
				or screenData.onScreen ~= onScreen
			then
				setScreenData({
					screenPoint = screenPoint,
					onScreen = onScreen,
				})
			end
		end)
		return function()
			connection:Disconnect()
		end
	end, {})

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
		Visible = screenData.onScreen,
		Size = getBoundingBoxSize(props),
		Position = (function()
			return UDim2.fromOffset(screenData.screenPoint.X, screenData.screenPoint.Y)
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
