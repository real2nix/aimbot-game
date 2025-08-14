local require = require(script.Parent.loader).load(script)

local SoundsServiceClient = {}
SoundsServiceClient.ServiceName = "SoundsServiceClient"

local SoundService = game:GetService("SoundService")

local Maid = require("Maid")

function SoundsServiceClient.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._gunServiceClient = serviceBag:GetService(require("GunServiceClient"))
	self._deathServiceClient = serviceBag:GetService(require("DeathServiceClient"))
	self._playerHurtServiceClient = serviceBag:GetService(require("PlayerHurtServiceClient"))

	-- Public
end

function SoundsServiceClient.Start(self)
	self._maid:Add(self._gunServiceClient.playerHitSignal:Connect(function()
		SoundService:FindFirstChild("PlayerHit"):Play()
	end))
	self._maid:Add(self._deathServiceClient.clientDiedSignal:Connect(function()
		SoundService:FindFirstChild("Died"):Play()
	end))
	self._maid:Add(self._playerHurtServiceClient.playerHurtSignal:Connect(function()
		SoundService:FindFirstChild("Hurt"):Play()
	end))
	self._maid:Add(self._gunServiceClient.shotSignal:Connect(function()
		SoundService:FindFirstChild("Shoot"):Play()
	end))
end

function SoundsServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

return SoundsServiceClient
