local require = require(script.Parent.loader).load(script)

local PlayerHitService = {}
PlayerHitService.ServiceName = "PlayerHitService"

local Maid = require("Maid")
local PlayerHitHighlightClass = require("PlayerHitHighlightClass")

function PlayerHitService.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._serviceBag = serviceBag
	self._gunServiceClient = serviceBag:GetService(require("GunServiceClient"))
	self._highlightServiceClient = serviceBag:GetService(require("HighlightServiceClient"))

	-- Public
end

function PlayerHitService.Start(self)
	self._gunServiceClient.playerHitSignal:Connect(function(data)
		PlayerHitHighlightClass.new(self._serviceBag, data.playerHit)
	end)
end

function PlayerHitService.Destroy(self)
	self._maid:DoCleaning()
end

return PlayerHitService
