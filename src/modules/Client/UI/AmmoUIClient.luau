local require = require(script.Parent.loader).load(script)

local AmmoUIClient = {}
AmmoUIClient.ServiceName = "AmmoUIClient"

local _ServiceBag = require("ServiceBag")
local ClientTypes = require("ClientTypes")
local React = require("react")
local ReactRoblox = require("react-roblox")
local AmmoQuantity = require("AmmoQuantity")
local Maid = require("Maid")

function AmmoUIClient.Init(self: ClientTypes.AmmoUIClient, serviceBag: _ServiceBag.ServiceBag)
	-- Private
	self._maid = Maid.new()
	self._screenGuiProvider = serviceBag:GetService(require("ScreenGuiProvider"))
	self._gunServiceClient = serviceBag:GetService(require("GunServiceClient"))
	self._root = ReactRoblox.createRoot(self._screenGuiProvider:Get("AMMO"))

	-- Public
end

function AmmoUIClient.Start(self: ClientTypes.AmmoUIClient)
	self._root:render(React.createElement(AmmoQuantity, { ammo = 5 }))
end

function AmmoUIClient.Destroy(self: ClientTypes.AmmoUIClient)
	self._maid:DoCleaning()
end

return AmmoUIClient
