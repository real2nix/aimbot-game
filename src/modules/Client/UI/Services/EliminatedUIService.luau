local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local require = require(script.Parent.loader).load(script)

local EliminatedUIService = {}
EliminatedUIService.ServiceName = "EliminatedUIService"

local Maid = require("Maid")
local AttributeUtils = require("AttributeUtils")
local EliminatedUI = require("EliminatedUI")

local function eliminatedContainer(props)
	local eliminateds, setEliminateds = React.useState({})
	local nextId, setNextId = React.useState(1)

	local removeEliminated = React.useCallback(function(id)
		setEliminateds(function(prevEliminateds)
			local newEliminateds = table.clone(prevEliminateds)
			newEliminateds[id] = nil
			return newEliminateds
		end)
	end)

	React.useEffect(function()
		props._gunServiceClient.playerHitSignal:Connect(function(data)
			local health: number = AttributeUtils.getAttribute(data.playerHit, "health", 0)
			if health - props._gunServiceClient.damagePerBullet.Value > 0 then
				return
			end
			setNextId(function(id)
				setEliminateds(function(prevEliminateds)
					local newEliminateds = table.clone(prevEliminateds)
					newEliminateds[id] = {
						onDestroy = removeEliminated,
						playerName = data.playerHit.Name,
						id = id,
					}
					return newEliminateds
				end)
				return id + 1
			end)
		end)
	end, {})

	local children =
		{ React.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}) }
	for id, data in eliminateds do
		children[id] = React.createElement(EliminatedUI, data)
	end

	return React.createElement("Frame", {
		Position = UDim2.fromScale(0, 1),
		AnchorPoint = Vector2.new(0, 1),
		Size = UDim2.fromScale(1, 0.3),
		BackgroundTransparency = 1,
	}, children)
end

function EliminatedUIService.Init(self, serviceBag)
	self._maid = Maid.new()
	self._serviceBag = serviceBag
	self._screenGuiProvider = serviceBag:GetService(require("ScreenGuiProvider"))
	self._gunServiceClient = serviceBag:GetService(require("GunServiceClient"))
end

function EliminatedUIService.Start(self)
	local handle = self._screenGuiProvider:Get("DAMAGE_DIRECTION")
	handle.IgnoreGuiInset = true
	self._root = ReactRoblox.createRoot(handle)
	self._root:render(React.createElement(eliminatedContainer, {
		_gunServiceClient = self._gunServiceClient,
	}))
end

function EliminatedUIService.Destroy(self)
	self._maid:DoCleaning()
end

return EliminatedUIService
