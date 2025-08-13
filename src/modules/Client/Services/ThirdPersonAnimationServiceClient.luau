local Players = game:GetService("Players")

local require = require(script.Parent.loader).load(script)

local ThirdPersonAnimationServiceClient = {}
ThirdPersonAnimationServiceClient.ServiceName = "ThirdPersonAnimationServiceClient"

local Maid = require("Maid")
local CharacterPromiseUtils = require("CharacterPromiseUtils")
local promiseChild = require("promiseChild")
local AnimationUtils = require("AnimationUtils")
local AnimationPromiseUtils = require("AnimationPromiseUtils")

function ThirdPersonAnimationServiceClient.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()

	-- Public
end

function ThirdPersonAnimationServiceClient.Start(self)
	self._maid:Add(CharacterPromiseUtils.promiseCharacter(Players.LocalPlayer):Then(function(character: Model)
		promiseChild(character, "Humanoid"):Then(function(humanoid)
			local animationTrack = AnimationUtils.getOrCreateAnimationTrack(
				humanoid.Animator,
				74613008615728,
				Enum.AnimationPriority.Action4
			)

			AnimationPromiseUtils.promiseLoaded(animationTrack):Then(function()
				animationTrack.Looped = true
				animationTrack:Play()
			end)
		end)
	end))
end

function ThirdPersonAnimationServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

return ThirdPersonAnimationServiceClient
