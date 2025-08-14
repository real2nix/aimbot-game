local require = require(script.Parent.loader).load(script)

local CoreGuiFeaturesServiceClient = {}
CoreGuiFeaturesServiceClient.ServiceName = "CoreGuiFeaturesServiceClient"

local Maid = require("Maid")
local CoreGuiUtils = require("CoreGuiUtils")

function CoreGuiFeaturesServiceClient.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()

	-- Public
end

function CoreGuiFeaturesServiceClient.Start(self)
	local success: boolean = CoreGuiUtils.tryToSetCore("ResetButtonCallback", false)
	if not success then
		self._maid:Add(CoreGuiUtils.promiseRetrySetCore(5, 1, "ResetButtonCallback", false))
	end
end

function CoreGuiFeaturesServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

return CoreGuiFeaturesServiceClient
