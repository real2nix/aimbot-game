local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")

local AmmoUI = {}
AmmoUI.ServiceName = "AmmoUI"

local function component(props)
	local ammo, updateAmmo = React.useState(props.gunServiceClient.ammo.Value)
	local maxAmmo, updateMaxAmmo = React.useState(props.gunServiceClient.maxAmmo.Value)

	React.useEffect(function()
		local connection = props.gunServiceClient.ammo.Changed:Connect(function(newValue)
			updateAmmo(newValue)
		end)
		return function()
			connection:Disconnect()
		end
	end, {})
	React.useEffect(function()
		local connection = props.gunServiceClient.maxAmmo.Changed:Connect(function(newValue)
			updateMaxAmmo(newValue)
		end)
		return function()
			connection:Disconnect()
		end
	end, {})

	return React.createElement("TextLabel", {
		AnchorPoint = Vector2.new(1, 1),
		Size = UDim2.fromScale(1, 0.0375),
		Position = UDim2.new(0.75, 0, 1 - 0.02, -15),
		Text = `{ammo} / {maxAmmo}`,
		Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Right,
		BackgroundTransparency = 1,
	})
end

function AmmoUI.Init(self, serviceBag)
	self._maid = Maid.new()
	self._gunServiceClient = serviceBag:GetService(require("GunServiceClient"))
	self._screenGuiProvider = serviceBag:GetService(require("ScreenGuiProvider"))
	self._root = nil
end

function AmmoUI.Start(self)
	local handle = self._screenGuiProvider:Get("AMMO")
	handle.IgnoreGuiInset = true
	self._root = ReactRoblox.createRoot(handle)
	self._root:render(React.createElement(component, {
		gunServiceClient = self._gunServiceClient,
	}))
end

function AmmoUI.Destroy(self)
	self._maid:DoCleaning()
end

return AmmoUI
