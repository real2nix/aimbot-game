local require = require(script.Parent.loader).load(script)

local DoubleJumpServiceClient = {}
DoubleJumpServiceClient.ServiceName = "DoubleJumpServiceClient"

local Maid = require("Maid")

function DoubleJumpServiceClient.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()

	-- Public
end

function DoubleJumpServiceClient.Start(self) end

function DoubleJumpServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

return DoubleJumpServiceClient
