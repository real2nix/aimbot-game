local Players = game:GetService("Players")
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
	HumanoidDescriptionUtils.promiseFromUserId(Players.LocalPlayer.UserId)
		:Then(function(humanoidDescription: HumanoidDescription)
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
