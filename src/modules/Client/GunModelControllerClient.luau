local require = require(script.Parent.loader).load(script)

local GunModelControllerClient = {}
GunModelControllerClient.ServiceName = "GunModelControllerClient"

local _ServiceBag = require("ServiceBag")
local ClientTypes = require("ClientTypes")
local Maid = require("Maid")

function GunModelControllerClient.Init(self: ClientTypes.GunModelControllerClient, serviceBag: _ServiceBag.ServiceBag)
	-- Private
	self._maid = Maid.new()

	-- Public
end

function GunModelControllerClient.Start(self: ClientTypes.GunModelControllerClient) end

function GunModelControllerClient.Destroy(self: ClientTypes.GunModelControllerClient)
	self._maid:DoCleaning()
end

return GunModelControllerClient
