local require = require(script.Parent.loader).load(script)

local GunServiceClient = {}
GunServiceClient.ServiceName = "GunServiceClient"

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local _ServiceBag = require("ServiceBag")
local ClientTypes = require("ClientTypes")
local DamageMarkerClient = require("DamageMarkerClient")
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

local REMOTE_EVENT_NAME: string = "GunController"

function GunServiceClient.Init(self: ClientTypes.GunServiceClient, ServiceBag: _ServiceBag.ServiceBag)
	self._maid = Maid.new()

	self._serviceBag = ServiceBag
	self._aimbotServiceClient = ServiceBag:GetService(require("AimbotServiceClient"))
	self._remoteEventPromise = PromiseGetRemoteEvent(REMOTE_EVENT_NAME)

	--[[
	States:
	unavailable
	ready
	shooting
	reloading

    should probably use something better than valueobject ??
	]]
	self.state = ValueObject.new("ready", "string")
	self.maxAmmo = ValueObject.new(20, "number")
	self.ammo = ValueObject.new(self.maxAmmo.Value, "number")
	self.reloadSeconds = ValueObject.new(1, "number")
	self.shootCooldownSeconds = ValueObject.new(0.115, "number")
	self.damagePerBullet = ValueObject.new(20, "number")

	self.reloadSignal = Signal.new()
	self.playerHitSignal = Signal.new()
	self.objectHitSignal = Signal.new()
end

function GunServiceClient.Start(self: ClientTypes.GunServiceClient)
	self._maid:Add(UserInputService.InputBegan:Connect(function(input)
		if self.state.Value == "ready" then
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				self:_startShooting()
			elseif input.KeyCode == Enum.KeyCode.R then
				self:_reload()
			end
		elseif self.state.Value == "shooting" then
			if input.KeyCode == Enum.KeyCode.R then
				self:_reload()
			end
		end
	end))

	self._maid:Add(UserInputService.InputEnded:Connect(function(input)
		if self.state.Value == "shooting" then
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				self.state:SetValue("ready")
			end
		end
	end))
end

function GunServiceClient.Destroy(self: ClientTypes.GunServiceClient)
	self._maid:DoCleaning()
end

function GunServiceClient._reload(self: ClientTypes.GunServiceClient)
	if self.ammo.Value == self.maxAmmo.Value then
		return
	end
	self.state:SetValue("reloading")
	self.reloadSignal:Fire()

	Promise.delay(self.reloadSeconds.Value, function()
		self.ammo:SetValue(self.maxAmmo.Value)
		self.state:SetValue("ready")
	end)
end

function GunServiceClient._shoot(self: ClientTypes.GunServiceClient)
	if not Players.LocalPlayer.Character or self.ammo.Value <= 0 then
		return
	end
	self.ammo:SetValue(self.ammo.Value - 1)
	local raycastResult: RaycastResult? = RaycastUtils.raycast(
		Camera.CFrame.Position,
		Camera.CFrame.LookVector * 1000,
		{ Players.LocalPlayer.Character, workspace.Ignore }
	)
	if not raycastResult then
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
	DamageMarkerClient.new(self._serviceBag, data)
	self.playerHitSignal:Fire(data)
	self._remoteEventPromise:Then(function(remoteEvent: RemoteEvent)
		remoteEvent:FireServer("shoot", data)
	end)
end

function GunServiceClient._startShooting(self: ClientTypes.GunServiceClient)
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

return GunServiceClient
