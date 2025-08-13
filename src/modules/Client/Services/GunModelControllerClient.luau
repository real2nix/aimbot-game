local require = require(script.Parent.loader).load(script)

local GunModelControllerClient = {}
GunModelControllerClient.ServiceName = "GunModelControllerClient"

local RunService: RunService = game:GetService("RunService")
local Players: Players = game:GetService("Players")
local UserInputService: UserInputService = game:GetService("UserInputService")

local Maid = require("Maid")
local CharacterPromiseUtils = require("CharacterPromiseUtils")
local CharacterUtils = require("CharacterUtils")
local promiseChild = require("promiseChild")

function GunModelControllerClient.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._gunServiceClient = serviceBag:GetService(require("GunServiceClient"))

	self._swayAmount = 2
	self._swaySpeed = 5
	self._bobAmount = 0.05
	self._bobSpeed = 7
	self._bobTime = 0
	self._lastMouseDelta = Vector2.zero
	self._movementIntensity = 0

	self._groundSmoothing = 1
	self._lastGroundState = 1
	self._smoothVerticalVelocity = 0
	self._fallVelocity = 0
	self._airTime = 0
	self._landingImpact = 0

	-- Recoil system
	self._recoilOffset = Vector3.new(0, 0, 0)
	self._recoilRotation = CFrame.new()
	self._recoilIntensity = 0.15 -- How much the gun kicks back (Z-axis)
	self._recoilUpward = 0.08 -- How much the gun kicks up (Y-axis)
	self._recoilRotationAmount = 0.12 -- How much the gun rotates upward (radians)
	self._recoilRecoverySpeed = 8 -- How fast recoil returns to normal

	-- Reload animation state
	self._reloadOffset = Vector3.new(0, 0, 0)
	self._isReloading = false
	self._reloadTime = self._gunServiceClient.reloadSeconds.Value -- How long the animation lasts (seconds)

	-- Public
end

function GunModelControllerClient.Start(self)
	self._gunServiceClient.gunModel.Parent = workspace.Ignore

	local function onCharacterRemoving()
		self._maid:DoCleaning()
	end

	local function onCharacterAdded()
		self._maid:DoCleaning()
		self._maid:Add(CharacterPromiseUtils.promiseCharacter(Players.LocalPlayer):Then(function(character: Model)
			self._maid:Add(self._gunServiceClient.shotSignal:Connect(function()
				-- Apply instant recoil when shot
				self._recoilOffset = Vector3.new(0, self._recoilUpward, self._recoilIntensity)
				self._recoilRotation = CFrame.Angles(self._recoilRotationAmount, 0, 0)
			end))
			self._maid:Add(self._gunServiceClient.reloadSignal:Connect(function()
				-- Trigger reload animation
				self._isReloading = true
				self._reloadTimer = 0
			end))

			self._maid:Add(promiseChild(Players.LocalPlayer.Character, "Humanoid"):Then(function(humanoid)
				self._maid:Add(humanoid.Died:Connect(onCharacterRemoving))
				self._maid:Add(RunService.PreRender:Connect(function(deltaTime: number)
					-- Smoothly recover recoil back to normal
					self._recoilOffset =
						self._recoilOffset:Lerp(Vector3.new(0, 0, 0), deltaTime * self._recoilRecoverySpeed)
					self._recoilRotation =
						self._recoilRotation:Lerp(CFrame.new(), deltaTime * self._recoilRecoverySpeed)

					-- Handle reload animation
					if self._isReloading then
						self._reloadTimer = self._reloadTimer + deltaTime
						local halfTime = self._reloadTime / 2

						if self._reloadTimer <= halfTime then
							-- First half: move gun down
							local t = self._reloadTimer / halfTime
							self._reloadOffset = Vector3.new(0, -math.sin(t * math.pi / 2) * 3, 0) -- move down
						elseif self._reloadTimer <= self._reloadTime then
							-- Second half: move gun back up
							local t = (self._reloadTimer - halfTime) / halfTime
							self._reloadOffset = Vector3.new(0, -math.sin((1 - t) * math.pi / 2) * 3, 0) -- move up
						else
							-- End animation
							self._reloadOffset = Vector3.new(0, 0, 0)
							self._isReloading = false
						end
					else
						self._reloadOffset = Vector3.new(0, 0, 0)
					end

					-- Track jump/fall state with smoothing
					local isOnGround = humanoid.FloorMaterial ~= Enum.Material.Air
					local verticalVelocity = 0

					if character.PrimaryPart then
						verticalVelocity = character.PrimaryPart.AssemblyLinearVelocity.Y
					end

					-- Smooth the ground state to reduce jitter
					self._groundSmoothing = self._groundSmoothing or 1
					if isOnGround then
						self._groundSmoothing = math.min(1, self._groundSmoothing + deltaTime * 8)
					else
						self._groundSmoothing = math.max(0, self._groundSmoothing - deltaTime * 4)
					end

					local smoothedGroundState = self._groundSmoothing

					-- Smooth vertical velocity
					self._smoothVerticalVelocity = self._smoothVerticalVelocity or 0
					self._smoothVerticalVelocity =
						math.lerp(self._smoothVerticalVelocity, verticalVelocity, deltaTime * 6)

					-- Detect landing with threshold
					if smoothedGroundState > 0.8 and self._lastGroundState < 0.2 and self._fallVelocity < -8 then
						-- Landing impact
						self._landingImpact = math.min(math.abs(self._fallVelocity) / 40, 0.8)
					end

					-- Update state tracking
					self._lastGroundState = smoothedGroundState
					if smoothedGroundState < 0.3 then
						self._fallVelocity = self._smoothVerticalVelocity
					end

					-- Get mouse delta for sway with smoothing
					local mouseDelta = UserInputService:GetMouseDelta()
					self._lastMouseDelta = self._lastMouseDelta:Lerp(mouseDelta, deltaTime * self._swaySpeed)

					-- Enhanced sway with rotation
					local swayX = -self._lastMouseDelta.X * self._swayAmount * 0.01
					local swayY = -self._lastMouseDelta.Y * self._swayAmount * 0.01
					local swayRotX = self._lastMouseDelta.Y * self._swayAmount * 0.002
					local swayRotY = -self._lastMouseDelta.X * self._swayAmount * 0.002

					-- Improved bobbing system
					local moveDirection = humanoid.MoveDirection
					local moveMagnitude = moveDirection.Magnitude
					local walkSpeed = humanoid.WalkSpeed or 16
					local currentSpeed = moveMagnitude * walkSpeed

					-- Always update bob time to prevent snapping
					if moveMagnitude > 0.1 then
						-- Increase bob time based on actual movement speed
						local speedMultiplier = math.min(currentSpeed / 16, 2) -- Cap at 2x normal speed
						self._bobTime += deltaTime * self._bobSpeed * speedMultiplier
					else
						-- Continue bobbing but at reduced rate to fade smoothly
						self._bobTime += deltaTime * self._bobSpeed * 0.1
					end

					-- Smooth movement intensity that fades gradually
					self._movementIntensity = self._movementIntensity or 0
					self._movementIntensity = math.lerp(self._movementIntensity, moveMagnitude, deltaTime * 8)

					-- Jump/Fall effects with smoothing
					local jumpSway = Vector3.new(0, 0, 0)
					local jumpRotation = CFrame.new()

					-- Only apply air effects when clearly not on ground
					if smoothedGroundState < 0.7 then
						-- In-air sway (floating/falling effect)
						local airTime = self._airTime or 0
						self._airTime = airTime + deltaTime

						-- Gentle floating motion while in air (reduced intensity)
						local airIntensity = 1 - smoothedGroundState
						jumpSway = Vector3.new(
							math.sin(airTime * 1.2) * 0.015 * airIntensity,
							math.sin(airTime * 0.6) * 0.02 * airIntensity,
							0
						)

						-- Slight rotation based on smoothed vertical velocity
						local pitchFromVelocity = math.clamp(self._smoothVerticalVelocity * 0.003, -0.08, 0.08)
						jumpRotation = CFrame.Angles(pitchFromVelocity * airIntensity, 0, 0)
					else
						-- Gradually reduce air time when on ground
						self._airTime = (self._airTime or 0) * (1 - deltaTime * 3)
					end

					-- Landing impact effect with smoother decay
					self._landingImpact = self._landingImpact or 0
					if self._landingImpact > 0.01 then
						-- Sharp downward then upward motion (reduced intensity)
						local impactPhase = (1 - self._landingImpact) * math.pi
						local impactOffset = Vector3.new(0, -math.sin(impactPhase) * 0.06 * self._landingImpact, 0)
						jumpSway = jumpSway + impactOffset

						-- Smoother decay of impact
						self._landingImpact = math.max(0, self._landingImpact - deltaTime * 3.5)
					end

					-- More realistic bobbing with multiple components using smooth intensity
					local bobVertical = math.sin(self._bobTime * 2) * self._bobAmount * self._movementIntensity
					local bobHorizontal = math.sin(self._bobTime) * self._bobAmount * 0.5 * self._movementIntensity
					local bobRotational = math.sin(self._bobTime * 1.5) * 0.02 * self._movementIntensity

					-- Create offset vectors
					local bobOffset = Vector3.new(bobHorizontal, bobVertical, 0)
					local swayOffset = Vector3.new(swayX, swayY, 0)

					-- Combine all movement effects including recoil
					local totalOffset = bobOffset + swayOffset + jumpSway + self._recoilOffset + self._reloadOffset

					-- Combine rotational components including recoil
					local swayRotation = CFrame.Angles(swayRotX, swayRotY, bobRotational)
					local totalRotation = swayRotation * jumpRotation * self._recoilRotation

					-- Base position offset (adjust these values to your preference)
					local baseOffset = Vector3.new(0.75, -0.5, -1.5)

					-- Combine all transformations
					local finalCFrame = workspace.CurrentCamera.CFrame
						* CFrame.new(baseOffset + totalOffset)
						* totalRotation

					self._gunServiceClient.gunModel:PivotTo(finalCFrame)
				end))
			end))
		end))
	end

	if Players.LocalPlayer.Character then
		onCharacterAdded()
	end
	Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
end

function GunModelControllerClient.Destroy(self)
	self._maid:DoCleaning()
end

return GunModelControllerClient
