local require = require(script.Parent.loader).load(script)

local FOVServiceClient = {}
FOVServiceClient.ServiceName = "FOVServiceClient"

local Maid = require("Maid")

function FOVServiceClient.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()

	-- Public
end

function FOVServiceClient.Start(self) end

function FOVServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

return FOVServiceClient
