local require = require(script.Parent.loader).load(script)

local AmmoUIClient = {}
AmmoUIClient.ServiceName = "AmmoUIClient"

local _ServiceBag = require("ServiceBag")
local ClientTypes = require("ClientTypes")
local ScreenGuiProvider = require("ScreenGuiProvider")
local GunServiceClient = require("GunServiceClient")
local Maid = require("Maid")
local Blend = require("Blend")

function AmmoUIClient.Init(self: ClientTypes.AmmoUIClient, serviceBag: _ServiceBag.ServiceBag)
	-- Private
	self._maid = Maid.new()
	self._screenGuiProvider = serviceBag:GetService(ScreenGuiProvider)
	self._gunServiceClient = serviceBag:GetService(GunServiceClient)
end

function AmmoUIClient.Start(self: ClientTypes.AmmoUIClient)
	local screenGui = self._screenGuiProvider:Get("AMMO")
	screenGui.IgnoreGuiInset = true

	self._maid:Add(Blend.New("TextLabel")({
		Text = Blend.Computed(self._gunServiceClient.ammo, self._gunServiceClient.maxAmmo, function(ammo, maxAmmo)
			return ammo .. " / " .. maxAmmo
		end),
		Position = UDim2.new(0.5, 0, 1, -35),
		Size = UDim2.new(1, 0, 0, 25),
		BackgroundTransparency = 1,
		TextScaled = true,
		AnchorPoint = Vector2.new(0.5, 1),
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.GothamBold,
		Parent = screenGui,
	}):Subscribe())
end

function AmmoUIClient.Destroy(self: ClientTypes.AmmoUIClient)
	self._maid:DoCleaning()
end

return AmmoUIClient
