local require = require(script.Parent.loader).load(script)

local PlayerClassClient = {}
PlayerClassClient.ClassName = "PlayerClassClient"
PlayerClassClient.__index = PlayerClassClient

local HighlightServiceClient = require("HighlightServiceClient")
local ScreenGuiProvider = require("ScreenGuiProvider")
local Maid = require("Maid")
local CharacterPromiseUtils = require("CharacterPromiseUtils")
local RxAttributeUtils = require("RxAttributeUtils")

function PlayerClassClient.new(serviceBag, player)
	local self = setmetatable({}, PlayerClassClient)

	self._maid = Maid.new()
	self._highlightServiceClient = serviceBag:GetService(HighlightServiceClient)
	self._screenGuiProvider = serviceBag:GetService(ScreenGuiProvider)
	self._forcefieldObject = nil

	CharacterPromiseUtils.promiseCharacter(player):Then(function(character: Model)
		local animatedHighlightModel = self._maid:Add(self._highlightServiceClient:Highlight(character, 1))
		animatedHighlightModel:SetHighlightDepthMode(Enum.HighlightDepthMode.AlwaysOnTop)
		animatedHighlightModel:SetFillColor(Color3.fromRGB(255, 0, 0))
		animatedHighlightModel:SetFillTransparency(0.8)
		animatedHighlightModel:SetOutlineTransparency(1)
	end)

	self._maid:Add(player:GetAttributeChangedSignal("health"):Connect(function()
		if player:GetAttribute("health") == 0 then
			if not self._maid._deadHighlight then
				local highlight = self._highlightServiceClient:Highlight(player.Character, 3)
				highlight:SetHighlightDepthMode(Enum.HighlightDepthMode.Occluded)
				highlight:SetFillColor(Color3.fromRGB(255, 255, 255))
				highlight:SetFillTransparency(0)
				highlight:SetOutlineTransparency(1)

				self._maid._deadHighlight = highlight
			end
		else
			self._maid._deadHighlight = nil
		end
	end))

	self._maid:Add(RxAttributeUtils.observeAttribute(player, "forcefield"):Subscribe(function(forcefieldValue: boolean)
		-- animate in if true,
		local transparency: number = if forcefieldValue == true then 0.2 else 1

		-- animate out if false
	end))

	return self
end

function PlayerClassClient.Destroy(self)
	self._maid:DoCleaning()
end

return PlayerClassClient
