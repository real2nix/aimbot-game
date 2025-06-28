local require = require(script.Parent.loader).load(script)

local DamageDirectionIndicatorUIClient = {}
DamageDirectionIndicatorUIClient.ClassName = "DamageUIClient"
DamageDirectionIndicatorUIClient.__index = DamageDirectionIndicatorUIClient

local RunService = game:GetService("RunService")

local Maid = require("Maid")
local Blend = require("Blend")
local ValueObject = require("ValueObject")
local SpringObject = require("SpringObject")

local Camera = workspace.CurrentCamera

function DamageDirectionIndicatorUIClient.new(ServiceBag, shooterPosition: Vector3)
	local self = setmetatable({}, DamageDirectionIndicatorUIClient)

	self._maid = Maid.new()
	self._screenGuiProvider = ServiceBag:GetService(require("ScreenGuiProvider"))
	self._angleDegrees = self._maid:Add(ValueObject.new(0, "number"))

	local transparencySpring = self._maid:Add(SpringObject.new(1, 5))
	transparencySpring:SetPosition(0)
	self._maid:Add(transparencySpring:Observe():Subscribe(function(value)
		if value >= 1 then
			self:Destroy()
		end
	end))

	local screenGui: ScreenGui = self._maid:Add(self._screenGuiProvider:Get("DAMAGE_INDICATOR"))
	screenGui.IgnoreGuiInset = true

	local function updateAngleDegrees(): ()
		local flatCFrame = CFrame.lookAt(
			Camera.CFrame.Position,
			Camera.CFrame.Position + Camera.CFrame.LookVector * Vector3.new(1, 0, 1)
		) -- basically just creates a cframe that has the position of your character's rootpart and the rotation of the camera WITHOUT the up/down rotation
		local travel = flatCFrame:Inverse() * shooterPosition -- find the travel distance from the flatCFrame to the enemy position (cf:inverse() * v3 is equivalent to cf:PointToObjectSpace(v3))
		local rot = math.atan2(travel.Z, travel.X)
		self._angleDegrees:SetValue(math.deg(rot) + 90)
	end
	updateAngleDegrees()

	self._maid:Add(RunService.RenderStepped:Connect(updateAngleDegrees))

	self._maid:Add(Blend.New("Frame")({
		Parent = screenGui,
		Size = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Rotation = self._angleDegrees:Observe(),
		BackgroundTransparency = 1,
		Blend.New("UIAspectRatioConstraint")({}),
		Blend.New("Frame")({
			BackgroundColor3 = Color3.fromRGB(255, 0, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(0.5, 0.05),
			BackgroundTransparency = transparencySpring:Observe(),
		}),
	}):Subscribe())

	return self
end

function DamageDirectionIndicatorUIClient:Destroy()
	self._maid:DoCleaning()
end

return DamageDirectionIndicatorUIClient
