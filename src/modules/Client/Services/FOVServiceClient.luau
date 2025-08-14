local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local require = require(script.Parent.loader).load(script)

local FOVServiceClient = {}
FOVServiceClient.ServiceName = "FOVServiceClient"

local Maid = require("Maid")
local SpringObject = require("SpringObject")
local CharacterPromiseUtils = require("CharacterPromiseUtils")
local promiseChild = require("promiseChild")

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
			promiseChild(character, "Humanoid"):Then(function(humanoid)
				local function update()
					local wasMoving = self._isMoving
					self._isMoving = humanoid.MoveDirection.Magnitude > 0
					if wasMoving ~= self._isMoving then
						if self._isMoving then
							self._fovSpring:SetTarget(self._movingFov)
						else
							self._fovSpring:SetTarget(self._baseFov)
						end
					end
					workspace.CurrentCamera.FieldOfView = self._fovSpring.Position
				end

				self._maid:GiveTask(RunService.RenderStepped:Connect(update))
				self._maid:Add(humanoid.Died:Connect(onCharacterRemoving))
			end)
		end))
	end

	if Players.LocalPlayer.Character then
		onCharacterAdded()
	end
	Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
end

function FOVServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

return FOVServiceClient
