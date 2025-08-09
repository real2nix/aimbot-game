local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage["react-lua"]["react"])
local ReactRoblox = require(ReplicatedStorage["react-lua"]["react-roblox"])
local RunService = game:GetService("RunService")

local require = require(script.Parent.loader).load(script)

local HitmarkerUIService = {}
HitmarkerUIService.ServiceName = "HitmarkerUIService"

local Maid = require("Maid")
local HitmarkerUI = require("HitmarkerUI")

local function HitmarkersContainer(props)
	local gunServiceClient = props.gunServiceClient
	local hitmarkers, setHitmarkers = React.useState({})
	local nextId, setNextId = React.useState(1)

	-- Listen for hit signals and add new hitmarkers
	React.useEffect(function()
		local connection = gunServiceClient.playerHitSignal:Connect(function(hitType)
			local id = nextId
			setNextId(id + 1)

			-- Add new hitmarker to collection
			setHitmarkers(function(currentHitmarkers)
				local newHitmarkers = {}
				for existingId, hitmarker in pairs(currentHitmarkers) do
					newHitmarkers[existingId] = hitmarker
				end

				newHitmarkers[id] = {
					id = id,
					hitType = hitType,
				}

				return newHitmarkers
			end)
		end)
		return function()
			connection:Disconnect()
		end
	end, { nextId })

	-- Function to remove hitmarker when it self-destructs
	local removeHitmarker = React.useCallback(function(id)
		setHitmarkers(function(currentHitmarkers)
			local newHitmarkers = {}
			for existingId, hitmarker in pairs(currentHitmarkers) do
				if existingId ~= id then
					newHitmarkers[existingId] = hitmarker
				end
			end
			return newHitmarkers
		end)
	end, {})

	local hitmarkerElements = {}
	for id, hitmarkerData in pairs(hitmarkers) do
		hitmarkerElements["Hitmarker_" .. id] = React.createElement(HitmarkerUI, {
			id = id,
			hitType = hitmarkerData.hitType,
			onDestroy = removeHitmarker,
			duration = 0.4, -- Slightly longer for better visibility
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
