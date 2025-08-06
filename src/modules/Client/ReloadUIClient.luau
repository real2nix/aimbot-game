local require = require(script.Parent.loader).load(script)

local ReloadUIClient = {}
ReloadUIClient.ServiceName = "ReloadUIClient"

local _ServiceBag = require("ServiceBag")
local ClientTypes = require("ClientTypes")
local Maid = require("Maid")
local Blend = require("Blend")
local Rx = require("Rx")
local ValueObject = require("ValueObject")
local ScreenGuiProvider = require("ScreenGuiProvider")
local GunServiceClient = require("GunServiceClient")

function ReloadUIClient.Init(self: ClientTypes.ReloadUIClient, ServiceBag: _ServiceBag.ServiceBag)
	-- Private
	self._maid = Maid.new()
	self._screenGuiProvider = ServiceBag:GetService(ScreenGuiProvider)
	self._gunServiceClient = ServiceBag:GetService(GunServiceClient)
	self._countValue = ValueObject.new(0, "number")
end

function ReloadUIClient.Start(self: ClientTypes.ReloadUIClient)
	self._gunServiceClient.reloadSignal:Connect(function()
		self._countValue:SetValue(self._gunServiceClient.reloadSeconds.Value)
		for i = self._countValue.Value * 10, 0, -1 do
			task.wait(0.1)
			self._countValue:SetValue(i / 10)
		end
	end)

	local screenGui = self._screenGuiProvider:Get("RELOAD_COUNTDOWN")
	screenGui.IgnoreGuiInset = true

	Blend.New("TextLabel")({
		Size = UDim2.fromOffset(30, 30),
		Position = UDim2.new(0.5, 5, 0.5, 5),
		BackgroundTransparency = 1,
		TextScaled = true,
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.GothamBold,
		Parent = screenGui,
		Visible = Blend.Computed(self._countValue, function(value)
			return value ~= 0
		end),

		Text = self._countValue:Observe():Pipe({
			Rx.map(function(seconds)
				return string.format("%.1f", seconds) .. "s"
			end),
		}),
	}):Subscribe()
end

function ReloadUIClient.Destroy(self: ClientTypes.ReloadUIClient)
	self._maid:DoCleaning()
end

return ReloadUIClient
