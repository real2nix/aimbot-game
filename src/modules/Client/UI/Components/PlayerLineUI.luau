local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local React = require(ReplicatedStorage.Packages.React)

local require = require(script.Parent.loader).load(script)

local CharacterUtils = require("CharacterUtils")
local AttributeUtils = require("AttributeUtils")

return function(props)
	local screenData, setScreenData = React.useState({ screenPoint = Vector3.new(), onScreen = false })

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

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		Visible = screenData.onScreen,
		BorderSizePixel = 0,
		Size = (function()
			return UDim2.new(
				0,
				(Vector2.new(screenData.screenPoint.X, screenData.screenPoint.Y) - Vector2.new(
					workspace.CurrentCamera.ViewportSize.X / 2,
					workspace.CurrentCamera.ViewportSize.Y / 2
				)).Magnitude,
				0,
				1
			)
		end)(),
		Position = (function()
			return UDim2.fromOffset(
				(workspace.CurrentCamera.ViewportSize.X / 2 + screenData.screenPoint.X) / 2,
				(workspace.CurrentCamera.ViewportSize.Y / 2 + screenData.screenPoint.Y) / 2
			)
		end)(),
		Rotation = (function()
			local centerX: number = workspace.CurrentCamera.ViewportSize.X / 2
			local centerY: number = workspace.CurrentCamera.ViewportSize.Y / 2

			local dirX: number = screenData.screenPoint.X - centerX
			local dirY: number = screenData.screenPoint.Y - centerY

			return math.deg(math.atan2(dirY, dirX))
		end)(),
	}, {})
end
