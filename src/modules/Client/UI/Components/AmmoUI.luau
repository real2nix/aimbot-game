local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage["react-lua"]["react"])
local ReactRoblox = require(ReplicatedStorage["react-lua"]["react-roblox"])

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")

local AmmoUI = {}
AmmoUI.ServiceName = "AmmoUI"

local function Bullet()
	return React.createElement("Frame", {
		Size = UDim2.fromScale(0.01, 1),
		BackgroundColor3 = Color3.fromRGB(255, 221, 0),
		BorderSizePixel = 0,
	}, {
		AspectRatio = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 0.35,
		}),
	})
end

local function RemainingBullets(props)
	local gunServiceClient = props.gunServiceClient
	local ammo, updateAmmo = React.useState(gunServiceClient.ammo.Value)

	-- must be a better way to do this
	React.useEffect(function()
		local connection = gunServiceClient.ammo.Changed:Connect(function()
			updateAmmo(gunServiceClient.ammo.Value)
		end)

		return function()
			connection:Disconnect()
		end
	end, { gunServiceClient })

	local bullets = {
		ListLayout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.0035, 0),
		}),
	}

	for i = 1, ammo do
		table.insert(bullets, React.createElement(Bullet))
	end

	return React.createElement("Frame", {
		Size = UDim2.new(1, 0, 0.05, 0),
		BackgroundTransparency = 1,
	}, bullets)
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
	self._root:render(React.createElement(RemainingBullets, {
		gunServiceClient = self._gunServiceClient,
	}))
end

function AmmoUI.Destroy(self)
	self._maid:DoCleaning()
end

return AmmoUI
