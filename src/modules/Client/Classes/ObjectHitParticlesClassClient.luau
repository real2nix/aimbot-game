local require = require(script.Parent.loader).load(script)

local ObjectHitParticlesClient = {}
ObjectHitParticlesClient.ClassName = "ObjectHitParticlesClient"
ObjectHitParticlesClient.__index = ObjectHitParticlesClient

local Maid = require("Maid")
local Blend = require("Blend")
local Promise = require("Promise")

local WIDTH: number = 0.25

function ObjectHitParticlesClient.new(serviceBag, data)
	local self = setmetatable({}, ObjectHitParticlesClient)

	self._maid = Maid.new()

	self:_addBulletHole(data)
	self:_addParticle(data)

	Promise.delay(7, function()
		self:Destroy()
	end)

	return self
end

function ObjectHitParticlesClient.Destroy(self)
	self._maid:DoCleaning()
end

function ObjectHitParticlesClient._addBulletHole(self, data)
	local cframe: CFrame = CFrame.new(data.position, data.position + data.normal)
	self._maid:Add(Blend.New("Part")({
		Name = "BulletHole",
		Parent = workspace.Ignore,
		CFrame = cframe,
		Anchored = true,
		CanCollide = false,
		Color = Color3.fromRGB(255, 255, 255),
		Size = Vector3.new(WIDTH, WIDTH, 0),
	}):Subscribe())
end

function ObjectHitParticlesClient._addParticle(self, data)
	local cframe: CFrame = CFrame.new(data.position, data.position + data.bulletUnitVector)
	self._maid:Add(Blend.New("Part")({
		Name = "Particles",
		Parent = workspace.Ignore,
		Anchored = true,
		CanCollide = false,
		Size = Vector3.new(WIDTH, WIDTH, 0),
		Transparency = 1,
		CFrame = cframe,
		Blend.New("ParticleEmitter")({
			EmissionDirection = Enum.NormalId.Back,
			Rate = 0,
			Speed = NumberRange.new(0.5),
			Lifetime = NumberRange.new(2),
			Texture = "rbxassetid://12533301072",
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.125),
				NumberSequenceKeypoint.new(1, 0.02),
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 0),
			}),
			[Blend.Instance] = function(v)
				v:Emit(3)
			end,
		}),
	}):Subscribe())
end

return ObjectHitParticlesClient
