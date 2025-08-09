local require = require(script.Parent.loader).load(script)

local PlayerClass = {}
PlayerClass.ClassName = "PlayerClass"
PlayerClass.__index = PlayerClass

local Maid = require("Maid")
local CharacterPromiseUtils = require("CharacterPromiseUtils")
local CharacterUtils = require("CharacterUtils")
local AttributeValue = require("AttributeValue")

local function _makePlayerCharacterBlocky(player: Player)
	local humanoid = CharacterUtils.getPlayerHumanoid(player)
	local currentDescription = humanoid:GetAppliedDescription()
	currentDescription.Head = 0
	currentDescription.Torso = 0
	currentDescription.LeftArm = 0
	currentDescription.RightArm = 0
	currentDescription.LeftLeg = 0
	currentDescription.RightLeg = 0
	humanoid:ApplyDescription(currentDescription)
end

function PlayerClass.new(serviceBag, player: Player)
	local self = setmetatable({}, PlayerClass)

	-- Private
	self._maid = Maid.new()
	self._player = player

	-- Public
	self.forcefield = true
	self.health = AttributeValue.new(player, "health", 150)

	self._maid:Add(player.CharacterAppearanceLoaded:Connect(function()
		self._maid:Add(CharacterPromiseUtils.promiseCharacter(player):Then(function(character)
			_makePlayerCharacterBlocky(player)
		end))
	end))

	return self
end

function PlayerClass.Destroy(self)
	self._maid:DoCleaning()
end

return PlayerClass
