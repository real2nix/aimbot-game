local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local React = require(ReplicatedStorage.Packages.React)

local DURATION_SECONDS = 1.5

return function(props)
	local transparency, setTransparency = React.useBinding(0)

	React.useEffect(function()
		local lifetime = 0
		local conn = RunService.Heartbeat:Connect(function(dt)
			lifetime += dt
			local alpha = math.clamp(lifetime / DURATION_SECONDS, 0, 1)
			setTransparency(alpha)

			if lifetime >= DURATION_SECONDS then
				props.onDestroy(props.id)
			end
		end)
		return function()
			conn:Disconnect()
		end
	end, {})

	return React.createElement("Part", {
		Size = Vector3.new(),
		Position = props.position + props.offset,
		Anchored = true,
		CanCollide = false,
		Transparency = 1,
	}, {
		React.createElement("BillboardGui", {
			Size = UDim2.fromOffset(25, 25),
			AlwaysOnTop = true,
		}, {
			React.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Text = props._gunServiceClient.damagePerBullet.Value,
				TextScaled = true,
				Font = Enum.Font.GothamBold,
				TextColor3 = Color3.fromRGB(255, 55, 55),
				TextTransparency = transparency,
			}, {
				React.createElement("UIStroke", {
					Thickness = 3,
					Color = Color3.fromRGB(126, 31, 31),
					Transparency = transparency,
				}),
			}),
		}),
	})
end
