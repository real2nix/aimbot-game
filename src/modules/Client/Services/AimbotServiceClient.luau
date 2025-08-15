local require = require(script.Parent.loader).load(script)

local AimbotServiceClient = {}
AimbotServiceClient.ServiceName = "AimbotServiceClient"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Maid = require("Maid")
local CharacterUtils = require("CharacterUtils")
local CharacterPromiseUtils = require("CharacterPromiseUtils")
local AttributeUtils = require("AttributeUtils")

local Camera: Camera = workspace.CurrentCamera

function AimbotServiceClient.Init(self, serviceBag)
	self._maid = Maid.new()
	self._aimbotMaid = self._maid:Add(Maid.new())

	self._gunServiceClient = serviceBag:GetService(require("GunServiceClient"))
	self._activePlayersServiceClient = serviceBag:GetService(require("ActivePlayersServiceClient"))

	self._params = RaycastParams.new()
	self._params.FilterType = Enum.RaycastFilterType.Exclude
end
-- target body parts
function AimbotServiceClient.Start(self)
	self._maid:Add(self._gunServiceClient.state.Changed:Connect(function(value: string)
		if value == "shooting" then
			self._aimbotMaid:Add(RunService.PreRender:Connect(function()
				local closestPlayer: Player?, rootPart = self:_getClosestPlayer()
				if not closestPlayer then
					return
				end
				Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, rootPart.Position)
			end))
		else
			self._aimbotMaid:DoCleaning()
		end
	end))
	self._maid:Add(CharacterPromiseUtils.promiseCharacter(Players.LocalPlayer):Then(function(character)
		self._params.FilterDescendantsInstances = { character }
	end))
end

function AimbotServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

function AimbotServiceClient._getClosestPlayer(self): Player?
	for _, player: Player in self._activePlayersServiceClient.activePlayers:GetList() do
		local health: number = AttributeUtils.getAttribute(player, "health", 0)
		if health == 0 then
			continue
		end
		local character: Model? = player.Character
		if not character then
			continue
		end
		local rootPart: Part? = CharacterUtils.getPlayerRootPart(player)
		if not rootPart then
			continue
		end
		-- Minimum dot product.
		local cameraToPlayer: Vector3 = rootPart.Position - Camera.CFrame.Position
		local raycastResult = workspace:Raycast(Camera.CFrame.Position, cameraToPlayer.Unit * 1000, self._params)
		if not raycastResult.Instance:IsDescendantOf(character) then
			return
		end
		if Camera.CFrame.LookVector.Unit:Dot(cameraToPlayer.Unit) < 0.95 then
			continue
		end
		return player, rootPart
	end
	return nil
end

--[[function AimbotServiceClient:_getClosestPlayerPart(player: Player): Part?
	if not player.Character then
		return nil
	end
	local limbsDot = {}
	for _, child in player.Character:GetChildren() do
		if not child:IsA("Part") then
			continue
		end
		local cameraToLimb = (child.CFrame.Position - Camera.CFrame.Position)
		local dot = Camera.CFrame.LookVector:Dot(cameraToLimb.Unit)
		table.insert(limbsDot, { part = child, dot = dot })
	end
	table.sort(limbsDot, function(a, b)
		return a.dot < b.dot
	end)
	return limbsDot[1].part
end]]

return AimbotServiceClient
