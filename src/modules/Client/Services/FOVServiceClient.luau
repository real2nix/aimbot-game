local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local require = require(script.Parent.loader).load(script)

local FOVServiceClient = {}
FOVServiceClient.ServiceName = "FOVServiceClient"

local Maid = require("Maid")
local SpringObject = require("SpringObject")
local CharacterPromiseUtils = require("CharacterPromiseUtils")
local CharacterUtils = require("CharacterUtils")

function FOVServiceClient.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._fovSpring = SpringObject.new(60, 14)

	-- FOV settings
	self._baseFov = 60
	self._movingFov = 70
	self._isMoving = false

	-- Public
end

function FOVServiceClient.Start(self)
	local function onCharacterRemoving()
		self._maid:DoCleaning()
	end

	local function onCharacterAdded()
		self._maid:Add(CharacterPromiseUtils.promiseCharacter(Players.LocalPlayer):Then(function(character: Model)
			-- Set up movement detection
			self:_setupMovementDetection()

			-- Set up FOV spring target updating
			self:_setupFOVUpdating()

			local humanoid = CharacterUtils.getPlayerHumanoid(Players.LocalPlayer)
			self._maid:Add(humanoid.Died:Connect(onCharacterRemoving))
		end))
	end

	-- Connect to character events
	if Players.LocalPlayer.Character then
		onCharacterAdded()
	end

	self._maid:GiveTask(Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded))
end

function FOVServiceClient._setupMovementDetection(self)
	-- Track movement using MoveVector (preferred method)
	local humanoid = CharacterUtils.getPlayerHumanoid(Players.LocalPlayer)
	local function checkMovement()
		local wasMoving = self._isMoving
		self._isMoving = humanoid.MoveDirection.Magnitude > 0

		-- Update FOV when movement state changes
		if wasMoving ~= self._isMoving then
			if self._isMoving then
				self._fovSpring:SetTarget(self._movingFov)
			else
				self._fovSpring:SetTarget(self._baseFov)
			end
		end
	end

	-- Check movement every frame
	self._maid:GiveTask(RunService.Heartbeat:Connect(checkMovement))
end

function FOVServiceClient._setupFOVUpdating(self)
	-- Connect spring position to camera FOV
	local camera = workspace.CurrentCamera

	local function updateCameraFOV()
		if camera then
			camera.FieldOfView = self._fovSpring.Position
		end
	end

	-- Update camera FOV every frame
	self._maid:GiveTask(RunService.RenderStepped:Connect(updateCameraFOV))
end

function FOVServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

return FOVServiceClient
