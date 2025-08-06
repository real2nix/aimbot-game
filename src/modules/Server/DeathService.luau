local require = require(script.Parent.loader).load(script)

local DeathService = {}
DeathService.ServiceName = "DeathService"

local _ServiceBag = require("ServiceBag")
local ServerTypes = require("ServerTypes")
local Maid = require("Maid")
local Signal = require("Signal")
local Ragdoll = require("Ragdoll")
local CharacterUtils = require("CharacterUtils")
local Promise = require("Promise")

function DeathService.Init(self: ServerTypes.DeathService, ServiceBag: _ServiceBag.ServiceBag)
	-- Private
	self._maid = Maid.new()
	self._activePlayersService = ServiceBag:GetService(require("ActivePlayersService"))
	self._gunService = ServiceBag:GetService(require("GunService"))

	-- Public
	self.playerDiedSignal = Signal.new()
end

function DeathService.Start(self: ServerTypes.DeathService)
	self._maid:Add(self._gunService.playerHitSignal:Connect(function(data)
		if data.playerHit:GetAttribute("health") > 0 then
			return
		end
		local rootPart: Part? = CharacterUtils.getPlayerRootPart(data.playerHit)
		if not rootPart then
			return
		end
		self.playerDiedSignal:Fire(data.playerHit)

		rootPart:SetNetworkOwner(nil)
		CharacterUtils.getPlayerHumanoid(data.playerHit):ChangeState(Enum.HumanoidStateType.Physics)
		Ragdoll:Tag(CharacterUtils.getPlayerHumanoid(data.playerHit))
		rootPart.AssemblyLinearVelocity = Vector3.new(65, 65, 65) * data.bulletUnitVector

		Promise.delay(5, function()
			Ragdoll:Untag(CharacterUtils.getPlayerHumanoid(data.playerHit))
			rootPart:SetNetworkOwnershipAuto()
		end)
	end))
end

function DeathService.Destroy(self: ServerTypes.DeathService)
	self._maid:DoCleaning()
end

return DeathService
