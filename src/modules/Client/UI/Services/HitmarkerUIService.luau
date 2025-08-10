local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local require = require(script.Parent.loader).load(script)

local HitmarkerUIService = {}
HitmarkerUIService.ServiceName = "HitmarkerUIService"

local Maid = require("Maid")
local HitmarkerUI = require("HitmarkerUI")

local function HitmarkersContainer(props)
	local hitmarkers, setHitmarkers = React.useState({})
	local nextId, setNextId = React.useState(1)

	React.useEffect(function()
		local connection = props.gunServiceClient.playerHitSignal:Connect(function()
			setNextId(function(prevId)
				local id = prevId
				setHitmarkers(function(currentHitmarkers)
					local newHitmarkers = table.clone(currentHitmarkers)
					newHitmarkers[id] = true
					return newHitmarkers
				end)
				return id + 1
			end)
		end)
		return function()
			connection:Disconnect()
		end
	end, {})

	local removeHitmarker = React.useCallback(function(id)
		setHitmarkers(function(currentHitmarkers)
			currentHitmarkers[id] = nil
			return currentHitmarkers
		end)
	end, {})

	local hitmarkerElements = {}
	for id in pairs(hitmarkers) do
		hitmarkerElements[id] = React.createElement(HitmarkerUI, {
			id = id,
			onDestroy = removeHitmarker,
		})
	end

	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, hitmarkerElements)
end

function HitmarkerUIService.Init(self, serviceBag)
	self._maid = Maid.new()
	self._gunServiceClient = serviceBag:GetService(require("GunServiceClient"))
	self._screenGuiProvider = serviceBag:GetService(require("ScreenGuiProvider"))
end

function HitmarkerUIService.Start(self)
	local handle = self._screenGuiProvider:Get("CROSSHAIR")
	handle.IgnoreGuiInset = true
	self._root = ReactRoblox.createRoot(handle)
	self._root:render(React.createElement(HitmarkersContainer, {
		gunServiceClient = self._gunServiceClient,
	}))
end

function HitmarkerUIService.Destroy(self)
	self._maid:DoCleaning()
end

return HitmarkerUIService
