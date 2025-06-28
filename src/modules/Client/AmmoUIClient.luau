local require = require(script.Parent.loader).load(script)

local AmmoUIClient = {}
AmmoUIClient.ServiceName = "AmmoUIClient"

local Maid = require("Maid")
local Blend = require("Blend")

function AmmoUIClient:Init(ServiceBag)
	-- Private
	self._maid = Maid.new()
	self._screenGuiProvider = ServiceBag:GetService(require("ScreenGuiProvider"))
	self._gunServiceClient = ServiceBag:GetService(require("GunServiceClient"))

	-- Public
end

function AmmoUIClient:Start()
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

function AmmoUIClient:Destroy()
	self._maid:DoCleaning()
end

return AmmoUIClient
