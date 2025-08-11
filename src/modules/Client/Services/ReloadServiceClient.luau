local require = require(script.Parent.loader).load(script)

local ReloadServiceClient = {}
ReloadServiceClient.ServiceName = "ReloadServiceClient"

local Maid = require("Maid")

function ReloadServiceClient.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._gunServiceClient = serviceBag:GetService(require("GunServiceClient"))

	-- Public
end

function ReloadServiceClient.Start(self)
	self._maid:Add(self._gunServiceClient.reloadSignal:Connect(function() end))
end

function ReloadServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

return ReloadServiceClient
