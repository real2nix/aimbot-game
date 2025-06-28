--[=[
	@class EntryClient
]=]

local require = require(script.Parent.loader).load(script)

local EntryClient = {}
EntryClient.ServiceName = "EntryClient"

function EntryClient:Init(serviceBag: _ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External
	self._serviceBag:GetService(require("CmdrServiceClient"))
	self._serviceBag:GetService(require("RagdollServiceClient"))
	self._serviceBag:GetService(require("HighlightServiceClient"))

	-- Internal
	self._serviceBag:GetService(require("AimbotTranslator"))
	self._serviceBag:GetService(require("GunServiceClient"))
	self._serviceBag:GetService(require("HealthServiceClient"))
	self._serviceBag:GetService(require("ReloadUIClient"))
	self._serviceBag:GetService(require("AmmoUIClient"))
	self._serviceBag:GetService(require("DamageDirectionIndicatorServiceClient"))
	self._serviceBag:GetService(require("HitmarkerServiceClient"))
	self._serviceBag:GetService(require("ObjectHitServiceClient"))
	self._serviceBag:GetService(require("EliminationServiceClient"))
end

return EntryClient
