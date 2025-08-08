local require = require(script.Parent.loader).load(script)

local GunModelControllerClient = {}
GunModelControllerClient.ServiceName = "GunModelControllerClient"

local RunService: RunService = game:GetService("RunService")
local Players: Players = game:GetService("Players")
local UserInputService: UserInputService = game:GetService("UserInputService")

local _ServiceBag = require("ServiceBag")
local ClientTypes = require("ClientTypes")
local Maid = require("Maid")
local CharacterPromiseUtils = require("CharacterPromiseUtils")

function GunModelControllerClient.Init(self: ClientTypes.GunModelControllerClient, serviceBag: _ServiceBag.ServiceBag)
	-- Private
	self._maid = Maid.new()
	self._gunServiceClient = serviceBag:GetService(require("GunServiceClient"))

	self._swayAmount = 0.05
	self._swaySpeed = 5
	self._bobAmount = 0.05
	self._bobSpeed = 10
	self._bobTime = 0
	self._lastMouseDelta = Vector2.zero

	-- Public
end

function GunModelControllerClient.Start(self: ClientTypes.GunModelControllerClient)
	self._maid:Add(CharacterPromiseUtils.promiseCharacter(Players.LocalPlayer):Then(function(character: Model)
		local humanoid: Humanoid = character:FindFirstChild("Humanoid") :: Humanoid

		--TODO check if playher is in 3rd person
		RunService.PreRender:Connect(function(deltaTime: number)
			-- Get mouse delta for sway
			local mouseDelta = UserInputService:GetMouseDelta()
			self._lastMouseDelta = self._lastMouseDelta:Lerp(mouseDelta, deltaTime * self._swaySpeed)

			-- Sway offset based on mouse movement
			local swayX = -self._lastMouseDelta.X * self._swayAmount
			local swayY = -self._lastMouseDelta.Y * self._swayAmount

			-- Bobbing when moving
			local moveDirection = humanoid.MoveDirection.Magnitude
			if moveDirection > 0 then
				self._bobTime += deltaTime * self._bobSpeed
			else
				self._bobTime = 0
			end

			local bobOffset = Vector3.new(0, math.sin(self._bobTime * 2) * self._bobAmount, 0)

			local swayOffset = CFrame.new(swayX, swayY, 0)
			local finalOffset = swayOffset * CFrame.new(bobOffset) * CFrame.new(0.5, -1, 0)

			self._gunServiceClient.gunModel:PivotTo(workspace.CurrentCamera.CFrame * finalOffset)
		end)
	end))
end

function GunModelControllerClient.Destroy(self: ClientTypes.GunModelControllerClient)
	self._maid:DoCleaning()
end

return GunModelControllerClient
