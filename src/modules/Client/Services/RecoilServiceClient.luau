local require = require(script.Parent.loader).load(script)

local RecoilServiceClient = {}
RecoilServiceClient.ServiceName = "RecoilServiceClient"

local RunService: RunService = game:GetService("RunService")

local Maid = require("Maid")

function RecoilServiceClient.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._gunServiceClient = serviceBag:GetService(require("GunServiceClient"))

	-- Camera recoil properties
	self._cameraRecoilIntensity = 0.005 -- How much the camera kicks up (radians, ~1.1 degrees)
	self._cameraRecoilRecoverySpeed = 20 -- How fast camera recoil fades (faster recovery)

	-- Current recoil state
	self._currentRecoilPitch = 0 -- Current upward recoil
	self._targetRecoilPitch = 0 -- Target recoil (instantly set on shot)

	-- Public
end

function RecoilServiceClient.Start(self)
	self._maid:Add(self._gunServiceClient.shotSignal:Connect(function()
		-- Apply instant recoil target (camera will smoothly move toward this)
		self._targetRecoilPitch = self._cameraRecoilIntensity
	end))

	-- Handle camera recoil smoothing (run after camera updates at priority 201)
	local function applyCameraRecoil(deltaTime: number)
		-- Smoothly move current recoil toward target recoil
		self._currentRecoilPitch = math.lerp(self._currentRecoilPitch, self._targetRecoilPitch, deltaTime * 20) -- Faster initial movement

		-- Gradually reduce target recoil back to zero (smooth recovery)
		self._targetRecoilPitch = math.lerp(self._targetRecoilPitch, 0, deltaTime * self._cameraRecoilRecoverySpeed)

		-- Apply recoil to camera
		if math.abs(self._currentRecoilPitch) > 0.001 then
			local currentCFrame = workspace.CurrentCamera.CFrame
			local recoilRotation = CFrame.Angles(self._currentRecoilPitch, 0, 0)
			workspace.CurrentCamera.CFrame = currentCFrame * recoilRotation
		end
	end

	-- Bind to render step with priority after camera (200 + 1 = 201)
	RunService:BindToRenderStep("CameraRecoil", Enum.RenderPriority.Camera.Value + 1, applyCameraRecoil)

	-- Clean up the binding when destroyed
	self._maid:Add(function()
		RunService:UnbindFromRenderStep("CameraRecoil")
	end)
end

function RecoilServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

return RecoilServiceClient
