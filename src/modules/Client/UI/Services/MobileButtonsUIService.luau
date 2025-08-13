local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local require = require(script.Parent.loader).load(script)

local MobileButtonsUIService = {}
MobileButtonsUIService.ServiceName = "MobileButtonsUIService"

local Maid = require("Maid")
local MobileButtonUI = require("MobileButtonUI")

local function component(props)
	local isTouch, updateIsTouch = React.useState(props._inputTypeServiceClient.isTouch.Value)
	React.useEffect(function()
		local connection = props._inputTypeServiceClient.isTouch.Changed:Connect(function(newValue)
			updateIsTouch(newValue)
		end)
		return function()
			connection:Disconnect()
		end
	end, {})

	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = isTouch,
	}, {
		Shoot = React.createElement(MobileButtonUI, {
			mouseButton1Down = function()
				if props._gunServiceClient.state.Value == "ready" then
					props._gunServiceClient.startShootingSignal:Fire()
				end
			end,
			mouseButton1Up = function()
				if props._gunServiceClient.state.Value == "shooting" then
					props._gunServiceClient.stopShootingSignal:Fire()
				end
			end,
			mouseExit = function()
				if props._gunServiceClient.state.Value == "shooting" then
					props._gunServiceClient.stopShootingSignal:Fire()
				end
			end,
			sizeOffset = 25,
			imageId = 123105545518463,
			positionOffset = Vector2.new(-35, 0),
			positioning = "above",
		}),
		Reload = React.createElement(MobileButtonUI, {
			mouseButton1Click = function()
				if
					(
						props._gunServiceClient.state.Value == "ready"
						or props._gunServiceClient.state.Value == "shooting"
					) and props._gunServiceClient.ammo.Value < props._gunServiceClient.maxAmmo.Value
				then
					props._gunServiceClient.reloadSignal:Fire()
				end
			end,
			imageId = 89929910879409,
			positionOffset = Vector2.new(0, -5),
			positioning = "left",
		}),
	})
end

function MobileButtonsUIService.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._screenGuiProvider = serviceBag:GetService(require("ScreenGuiProvider"))
	self._gunServiceClient = serviceBag:GetService(require("GunServiceClient"))
	self._inputTypeServiceClient = serviceBag:GetService(require("InputTypeServiceClient"))
	self._root = nil
end

function MobileButtonsUIService.Start(self)
	local handle = self._screenGuiProvider:Get("MOBILE_BUTTONS")
	self._root = ReactRoblox.createRoot(handle)
	self._root:render(React.createElement(component, {
		_gunServiceClient = self._gunServiceClient,
		_inputTypeServiceClient = self._inputTypeServiceClient,
	}))
end

function MobileButtonsUIService.Destroy(self)
	self._maid:DoCleaning()
end

return MobileButtonsUIService
