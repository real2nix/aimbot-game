local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local React = require(ReplicatedStorage.Packages.React)

local require = require(script.Parent.loader).load(script)

local SpringObject = require("SpringObject")
local Maid = require("Maid")

return function(props)
	local function getRotation(): number
		local flatCFrame = CFrame.lookAt(
			workspace.CurrentCamera.CFrame.Position,
			workspace.CurrentCamera.CFrame.Position + workspace.CurrentCamera.CFrame.LookVector * Vector3.new(1, 0, 1)
		)
		local travel = flatCFrame:Inverse() * props.shooterPosition
		local rot = math.atan2(travel.Z, travel.X)
		return math.deg(rot) + 90
	end

	local rotation, setRotation = React.useState(getRotation())
	local transparency, setTransparency = React.useState(1)

	React.useEffect(function()
		local maid = Maid.new()
		maid:Add(RunService.PreRender:Connect(function()
			setRotation(getRotation())
		end))

		local transparencySpring = maid:Add(SpringObject.new(1, 5))
		transparencySpring:SetPosition(0)
		maid:Add(transparencySpring:Observe():Subscribe(function(value)
			if value >= 1 then
				props.onDestroy(props.id)
			end
			setTransparency(value)
		end))

		return function()
			maid:DoCleaning()
		end
	end, {})

	return React.createElement("Frame", {
		Size = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Rotation = rotation,
		BackgroundTransparency = 1,
	}, {
		React.createElement("UIAspectRatioConstraint", {}),
		React.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 0, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(0.5, 0.05),
			BorderSizePixel = 0,
			BackgroundTransparency = transparency,
		}),
	})
end
