local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local require = require(script.Parent.loader).load(script)

local DamageDirectionUIService = {}
DamageDirectionUIService.ServiceName = "DamageDirectionUIServiceClient"

local Maid = require("Maid")
local DamageDirectionUI = require("DamageDirectionUI")

local function damageDirectionsContainer(props)
	local damageDirections, setDamageDirections = React.useState({})
	local nextId, setNextId = React.useState(1)

	React.useEffect(function()
		props._playerHurtServiceClient.playerHurtSignal:Connect(function(data)
			setNextId(function(id)
				setDamageDirections(function(prevDamageDirections)
					local newDamageDirections = table.clone(prevDamageDirections)
					newDamageDirections[id] = {
						shooterPosition = data.shooterPosition,
					}
					return newDamageDirections
				end)
				return id + 1
			end)
		end)
	end, {})

	local removeDamageDirection = React.useCallback(function(id)
		setDamageDirections(function(prevDamageDirections)
			local newDamageDirections = table.clone(prevDamageDirections)
			newDamageDirections[id] = nil
			return newDamageDirections
		end)
	end)

	local children = {}
	for id, data in damageDirections do
		children[id] = React.createElement(DamageDirectionUI, {
			id = id,
			shooterPosition = data.shooterPosition,
			onDestroy = removeDamageDirection,
		})
	end

	return React.createElement("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) }, children)
end

function DamageDirectionUIService.Init(self, serviceBag)
	self._maid = Maid.new()
	self._serviceBag = serviceBag
	self._screenGuiProvider = serviceBag:GetService(require("ScreenGuiProvider"))
	self._playerHurtServiceClient = serviceBag:GetService(require("PlayerHurtServiceClient"))
end

function DamageDirectionUIService.Start(self)
	local handle = self._screenGuiProvider:Get("DAMAGE_DIRECTION")
	handle.IgnoreGuiInset = true
	self._root = ReactRoblox.createRoot(handle)
	self._root:render(React.createElement(damageDirectionsContainer, {
		_playerHurtServiceClient = self._playerHurtServiceClient,
	}))
end

function DamageDirectionUIService.Destroy(self)
	self._maid:DoCleaning()
end

return DamageDirectionUIService
