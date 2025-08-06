local require = require(script.Parent.loader).load(script)

local InputTypeServiceClient = {}
InputTypeServiceClient.ServiceName = "InputTypeServiceClient"

local UserInputService: UserInputService = game:GetService("UserInputService")

local _ServiceBag = require("ServiceBag")
local ClientTypes = require("ClientTypes")
local Maid = require("Maid")
local PromiseGetRemoteEvent = require("PromiseGetRemoteEvent")

local REMOTE_EVENT_NAME: string = "DAMAGE_INDICATOR"

function InputTypeServiceClient.Init(self: ClientTypes.InputTypeServiceClient, serviceBag: _ServiceBag.ServiceBag)
	-- Private
	self._maid = Maid.new()
	self._serviceBag = serviceBag
end

function InputTypeServiceClient.Start(self: ClientTypes.InputTypeServiceClient) end

function InputTypeServiceClient.Destroy(self: ClientTypes.InputTypeServiceClient)
	self._maid:DoCleaning()
end

return InputTypeServiceClient
