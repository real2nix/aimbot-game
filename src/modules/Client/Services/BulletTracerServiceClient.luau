local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local require = require(script.Parent.loader).load(script)

local BulletTracerServiceClient = {}
BulletTracerServiceClient.ServiceName = "BulletTracerServiceClient"

local Maid = require("Maid")
local Promise = require("Promise")

function BulletTracerServiceClient.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._gunServiceClient = serviceBag:GetService(require("GunServiceClient"))

	-- Public
end

function BulletTracerServiceClient.Start(self)
	self._maid:Add(self._gunServiceClient.missSignal:Connect(function()
		local endPoint = workspace.CurrentCamera.CFrame.Position + workspace.CurrentCamera.CFrame.LookVector * 100
		self:_createTracer(endPoint)
	end))
	self._maid:Add(self._gunServiceClient.playerHitSignal:Connect(function(data)
		self:_createTracer(data.position)
	end))
	self._maid:Add(self._gunServiceClient.objectHitSignal:Connect(function(data)
		self:_createTracer(data.position)
	end))
end

function BulletTracerServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

function BulletTracerServiceClient._createTracer(self, endPosition: Vector3)
	local bulletTracer = ReplicatedStorage.Assets.BulletTracer:Clone()
	bulletTracer.Start.Position = self._gunServiceClient.gunModel.Tip.Position
	bulletTracer.End.Position = endPosition
	bulletTracer.Parent = workspace.Ignore

	local connection = RunService.PreRender:Connect(function()
		bulletTracer.Start.Position = self._gunServiceClient.gunModel.Tip.Position
	end)
	Promise.delay(0.025, function()
		connection:Disconnect()
		bulletTracer:Destroy()
	end)
end

return BulletTracerServiceClient
