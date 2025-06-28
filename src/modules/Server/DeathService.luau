local require = require(script.Parent.loader).load(script)

local DeathService = {}
DeathService.ServiceName = "DeathService"

local Maid = require("Maid")
local Signal = require("Signal")
local Ragdoll = require("Ragdoll")
local CharacterUtils = require("CharacterUtils")
local CharacterPromiseUtils = require("CharacterPromiseUtils")
local Promise = require("Promise")

function DeathService:Init(ServiceBag)
	-- Private
	self._maid = Maid.new()
	self._activePlayersService = ServiceBag:GetService(require("ActivePlayersService"))
	self._gunService = ServiceBag:GetService(require("GunService"))
end

function DeathService:Start()
	self._maid:Add(self._gunService.playerHitSignal:Connect(function(data)
		if data.playerHit:GetAttribute("health") ~= 0 then
			return
		end
		local rootPart: Part? = CharacterUtils.getPlayerRootPart(data.playerHit)
		if not rootPart then
			return
		end
		rootPart:SetNetworkOwner(nil)
		CharacterUtils.getPlayerHumanoid(data.playerHit):ChangeState(Enum.HumanoidStateType.Physics)
		Ragdoll:Tag(CharacterUtils.getPlayerHumanoid(data.playerHit))
		rootPart.AssemblyLinearVelocity = Vector3.new(65, 65, 65) * data.bulletUnitVector

		Promise.delay(5, function()
			Ragdoll:Untag(CharacterUtils.getPlayerHumanoid(data.playerHit))
			rootPart:SetNetworkOwnershipAuto()
			self._activePlayersService.activePlayers[data.playerHit].health.Value = 150
		end)
	end))
end

function DeathService:Destroy()
	self._maid:DoCleaning()
end

return DeathService
