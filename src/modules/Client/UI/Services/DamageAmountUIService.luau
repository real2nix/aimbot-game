local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local require = require(script.Parent.loader).load(script)

local DamageAmountUIService = {}
DamageAmountUIService.ServiceName = "DamageAmountUIService"

local Maid = require("Maid")
local DamageAmountUI = require("DamageAmountUI")

function DamageAmountUIService.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._gunServiceClient = serviceBag:GetService(require("GunServiceClient"))
	self._root = nil
end

local function DamageAmountContainer(props)
	local damageList, setDamageList = React.useState({})
	local nextId, setNextId = React.useState(1)
	React.useEffect(function()
		local connection = props._gunServiceClient.playerHitSignal:Connect(function(data)
			setNextId(function(id)
				setDamageList(function(prevDamageList)
					local newDamageList = table.clone(prevDamageList)
					newDamageList[id] = {
						position = data.position,
						instance = data.instance,
						distance = data.distance,
						bulletUnitVector = data.bulletUnitVector,
						offset = CFrame.fromAxisAngle(data.bulletUnitVector, math.random() * 2 * math.pi).RightVector
							* (data.distance / 100 + math.random(10, 35) / 10),
					}
					return newDamageList
				end)
				return id + 1
			end)
		end)
		return function()
			connection:Disconnect()
		end
	end, {})

	local removeDamageAmountUI = React.useCallback(function(id)
		setDamageList(function(prevDamageList)
			prevDamageList[id] = nil
			return prevDamageList
		end)
	end)

	local children = {}
	for id, data in damageList do
		children[id] = React.createElement(DamageAmountUI, {
			id = id,
			position = data.position,
			instance = data.instance,
			distance = data.distance,
			bulletUnitVector = data.bulletUnitVector,
			offset = data.offset,
			onDestroy = removeDamageAmountUI,
			_gunServiceClient = props._gunServiceClient,
		})
	end
	return React.createElement("Folder", {}, children)
end

function DamageAmountUIService.Start(self)
	local handle = Instance.new("Folder", workspace:FindFirstChild("Ignore"))
	self._root = ReactRoblox.createRoot(handle)
	self._root:render(React.createElement(DamageAmountContainer, {
		_gunServiceClient = self._gunServiceClient,
	}))
end

function DamageAmountUIService.Destroy(self)
	self._maid:DoCleaning()
end

return DamageAmountUIService
