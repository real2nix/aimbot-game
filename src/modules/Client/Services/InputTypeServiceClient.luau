local require = require(script.Parent.loader).load(script)

local InputTypeServiceClient = {}
InputTypeServiceClient.ServiceName = "InputTypeServiceClient"

local UserInputService: UserInputService = game:GetService("UserInputService")

local ValueObject = require("ValueObject")
local Maid = require("Maid")

function InputTypeServiceClient.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._serviceBag = serviceBag

	-- Public
	self.isTouch = self._maid:Add(ValueObject.new(false, "boolean"))
end

function InputTypeServiceClient.Start(self)
	self._maid:Add(UserInputService.TouchStarted:Connect(function()
		self.isTouch:SetValue(true)
	end))
	self._maid:Add(UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Touch then
			self.isTouch:SetValue(false)
		end
	end))
end

function InputTypeServiceClient.Destroy(self)
	self._maid:DoCleaning()
end

return InputTypeServiceClient
