local require = require(script.Parent.loader).load(script)

local GunServiceClient = {}
GunServiceClient.ServiceName = "GunServiceClient"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Maid = require("Maid")
local Signal = require("Signal")
local ValueObject = require("ValueObject")
local Rx = require("Rx")
local RaycastUtils = require("RaycastUtils")
local CharacterUtils = require("CharacterUtils")
local PromiseGetRemoteEvent = require("PromiseGetRemoteEvent")
local Promise = require("Promise")
local AttributeUtils = require("AttributeUtils")

local Camera = workspace.CurrentCamera

type state = "unavailable" | "ready" | "shooting" | "reloading"

local REMOTE_EVENT_NAME: string = "GunController"

function GunServiceClient.Init(self, serviceBag)
	self._maid = Maid.new()

	self._serviceBag = serviceBag
	self._aimbotServiceClient = serviceBag:GetService(require("AimbotServiceClient"))
	self._remoteEventPromise = PromiseGetRemoteEvent(REMOTE_EVENT_NAME)

	self.state = self._maid:Add(ValueObject.new("ready", "string"))
	self.maxAmmo = self._maid:Add(ValueObject.new(20, "number"))
	self.ammo = self._maid:Add(ValueObject.new(self.maxAmmo.Value, "number"))
	self.reloadSeconds = self._maid:Add(ValueObject.new(1, "number"))
	self.shootCooldownSeconds = self._maid:Add(ValueObject.new(0.115, "number"))
	self.damagePerBullet = self._maid:Add(ValueObject.new(20, "number"))
	self.gunModel = ReplicatedStorage.Assets.Guns.AK47:Clone()

	self.reloadSignal = self._maid:Add(Signal.new())
	self.startShootingSignal = self._maid:Add(Signal.new())
	self.stopShootingSignal = self._maid:Add(Signal.new())
	self.shotSignal = self._maid:Add(Signal.new())
	self.missSignal = self._maid:Add(Signal.new())
	self.playerHitSignal = self._maid:Add(Signal.new())
	self.objectHitSignal = self._maid:Add(Signal.new())
end

function GunServiceClient.Start(self)
	self._maid:Add(UserInputService.InputBegan:Connect(function(input)
		if self.state.Value == "ready" then
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				self.startShootingSignal:Fire()
			elseif input.KeyCode == Enum.KeyCode.R and self.ammo.Value < self.maxAmmo.Value then
				self.reloadSignal:Fire()
			end
		elseif self.state.Value == "shooting" then
			if input.KeyCode == Enum.KeyCode.R and self.ammo.Value < self.maxAmmo.Value then
				self.reloadSignal:Fire()
			end
		end
	end))

	self._maid:Add(UserInputService.InputEnded:Connect(function(input)
		if self.state.Value == "shooting" then
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				self.stopShootingSignal:Fire()
			end
		end
	end))

	self._maid:Add(self.startShootingSignal:Connect(function()
		if self.state.Value == "ready" then
			self:_startShooting()
		end
	end))
	self._maid:Add(self.stopShootingSignal:Connect(function()
		if self.state.Value == "shooting" then
			self:_stopShooting()
		end
	end))
	self._maid:Add(self.reloadSignal:Connect(function()
		self:_reload()
	end))
end

function GunServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

function GunServiceClient._reload(self)
	self.state:SetValue("reloading")

	Promise.delay(self.reloadSeconds.Value, function()
		self.ammo:SetValue(self.maxAmmo.Value)
		self.state:SetValue("ready")
	end)
end

function GunServiceClient._shoot(self)
	if not Players.LocalPlayer.Character or self.ammo.Value <= 0 then
		return
	end
	self.shotSignal:Fire()
	self.ammo:SetValue(self.ammo.Value - 1)
	local raycastResult: RaycastResult? = RaycastUtils.raycast(
		Camera.CFrame.Position,
		Camera.CFrame.LookVector * 1000,
		{ Players.LocalPlayer.Character, workspace.Ignore }
	)
	if not raycastResult then
		self.missSignal:Fire()
		return
	end
	local playerHit: Player? = CharacterUtils.getPlayerFromCharacter(raycastResult.Instance)
	if not playerHit then
		self.objectHitSignal:Fire({
			position = raycastResult.Position,
			instance = raycastResult.Instance,
			normal = raycastResult.Normal,
			bulletUnitVector = Camera.CFrame.LookVector,
		})
		return
	end
	local health: number = AttributeUtils.getAttribute(playerHit, "health", 0)
	if health == 0 then
		return
	end
	local data = {
		position = raycastResult.Position,
		instance = raycastResult.Instance,
		distance = raycastResult.Distance,
		playerHit = playerHit,
		playerShooter = Players.LocalPlayer,
		bulletUnitVector = Camera.CFrame.LookVector,
	}
	self.playerHitSignal:Fire(data)
	self._remoteEventPromise:Then(function(remoteEvent: RemoteEvent)
		remoteEvent:FireServer("shoot", data)
	end)
end

function GunServiceClient._startShooting(self)
	local maid = Maid.new()
	self.state:SetValue("shooting")

	maid:Add(Rx.interval(self.shootCooldownSeconds.Value):Subscribe(function()
		self:_shoot()
	end))
	maid:Add(self.state.Changed:Connect(function(value)
		if value ~= "shooting" then
			maid:DoCleaning()
		end
	end))
end

function GunServiceClient._stopShooting(self)
	self.state:SetValue("ready")
end

return GunServiceClient
