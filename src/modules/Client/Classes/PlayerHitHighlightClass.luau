local require = require(script.Parent.loader).load(script)

local PlayerHitHighlightClass = {}
PlayerHitHighlightClass.ClassName = "PlayerHitHighlightClass"
PlayerHitHighlightClass.__index = PlayerHitHighlightClass

local Maid = require("Maid")
local SpringObject = require("SpringObject")
local Promise = require("Promise")

function PlayerHitHighlightClass.new(serviceBag, playerHit)
	local self = setmetatable({}, PlayerHitHighlightClass)

	self._maid = Maid.new()
	self._highlightServiceClient = serviceBag:GetService(require("HighlightServiceClient"))

	local transparencySpring = self._maid:Add(SpringObject.new(5, 10, 3))
	transparencySpring:SetPosition(0)
	self._maid:Add(transparencySpring:Observe():Subscribe(function(value)
		if value >= 0.9 then
			self:Destroy()
		end
	end))

	local animatedHighlightModel = self._maid:Add(self._highlightServiceClient:Highlight(playerHit.Character, 2))
	animatedHighlightModel:SetHighlightDepthMode(Enum.HighlightDepthMode.AlwaysOnTop)
	animatedHighlightModel:SetSpeed(2.5)
	animatedHighlightModel:SetFillTransparency(0)
	animatedHighlightModel:SetFillColor(Color3.fromRGB(255, 255, 255))
	animatedHighlightModel:SetOutlineTransparency(1)

	self._maid:Add(Promise.delay(0.05, function()
		animatedHighlightModel:SetFillTransparency(1)
	end))

	return self
end

function PlayerHitHighlightClass.Destroy(self)
	self._maid:DoCleaning()
end

return PlayerHitHighlightClass
