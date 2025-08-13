local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local require = require(script.Parent.loader).load(script)

local ArmColorServiceClient = {}
ArmColorServiceClient.ServiceName = "ArmColorServiceClient"

local Maid = require("Maid")
local promiseChild = require("promiseChild")
local HumanoidDescriptionUtils = require("HumanoidDescriptionUtils")

function ArmColorServiceClient.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._gunServiceClient = serviceBag:GetService(require("GunServiceClient"))

	-- Public
end

function ArmColorServiceClient.Start(self)
	local userId = Players.LocalPlayer.UserId
	if RunService:IsStudio() then
		userId = 33295715
	end
	HumanoidDescriptionUtils.promiseFromUserId(userId):Then(function(humanoidDescription: HumanoidDescription)
		promiseChild(self._gunServiceClient.gunModel, "LeftArm"):Then(function(arm)
			arm.Color = humanoidDescription.LeftArmColor
		end)
		promiseChild(self._gunServiceClient.gunModel, "RightArm"):Then(function(arm)
			arm.Color = humanoidDescription.RightArmColor
		end)
	end)
end

function ArmColorServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

return ArmColorServiceClient
