--[=[
	@class Entry
]=]

local require = require(script.Parent.loader).load(script)

local _ServiceBag = require("ServiceBag")

local Entry = {}
Entry.ServiceName = "Entry"

function Entry:Init(serviceBag: _ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External
	self._serviceBag:GetService(require("CmdrService"))
	self._serviceBag:GetService(require("RagdollService"))

	-- Internal
	self._serviceBag:GetService(require("AimbotTranslator"))
	self._serviceBag:GetService(require("ActivePlayersService"))
	self._serviceBag:GetService(require("GunService"))
	self._serviceBag:GetService(require("DeathService"))
	self._serviceBag:GetService(require("SpawnPlayerService"))
	self._serviceBag:GetService(require("DamageDirectionIndicatorService"))
end

return Entry
