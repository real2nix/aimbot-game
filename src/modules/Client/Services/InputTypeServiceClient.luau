local require = require(script.Parent.loader).load(script)

local InputTypeServiceClient = {}
InputTypeServiceClient.ServiceName = "InputTypeServiceClient"

local UserInputService: UserInputService = game:GetService("UserInputService")

local Maid = require("Maid")
local PromiseGetRemoteEvent = require("PromiseGetRemoteEvent")

local REMOTE_EVENT_NAME: string = "DAMAGE_INDICATOR"

function InputTypeServiceClient.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._serviceBag = serviceBag
end

function InputTypeServiceClient.Start(self) end

function InputTypeServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

return InputTypeServiceClient
