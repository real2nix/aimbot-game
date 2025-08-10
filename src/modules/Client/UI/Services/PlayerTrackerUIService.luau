local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local require = require(script.Parent.loader).load(script)

local PlayerTrackerUIService = {}
PlayerTrackerUIService.ServiceName = "PlayerTrackerUIService"

local Maid = require("Maid")
local CharacterPromiseUtils = require("CharacterPromiseUtils")
local PlayerLineUI = require("PlayerLineUI")
local PlayerBoxUI = require("PlayerBoxUI")

local function playerTrackerContainer(props)
	local activePlayers, setActivePlayers = React.useState({})

	React.useEffect(function()
		for _, player in props._activePlayersService.activePlayers:GetList() do
			CharacterPromiseUtils.promiseCharacter(player):Then(function(character: Model)
				setActivePlayers(function(prevActivePlayers)
					local newActivePlayers = table.clone(prevActivePlayers)
					newActivePlayers[player] = {
						character = character,
						characterSize = character:GetExtentsSize(),
						player = player,
					}
					return newActivePlayers
				end)
			end)
		end
		props._activePlayersService.activePlayers.ItemAdded:Connect(function(player)
			CharacterPromiseUtils.promiseCharacter(player):Then(function(character: Model)
				setActivePlayers(function(prevActivePlayers)
					local newActivePlayers = table.clone(prevActivePlayers)
					newActivePlayers[player] = {
						character = character,
						characterSize = character:GetExtentsSize(),
						player = player,
					}
					return newActivePlayers
				end)
			end)
		end)
		props._activePlayersService.activePlayers.ItemRemoved:Connect(function(player)
			setActivePlayers(function(prevActivePlayers)
				local newActivePlayers = table.clone(prevActivePlayers)
				newActivePlayers[player] = nil
				return newActivePlayers
			end)
		end)
	end, {})

	local children = {}
	for player, data in activePlayers do
		table.insert(
			children,
			React.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}, {
				React.createElement(PlayerLineUI, data),
				React.createElement(PlayerBoxUI, data),
			})
		)
	end

	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, children)
end

function PlayerTrackerUIService.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._screenGuiProvider = serviceBag:GetService(require("ScreenGuiProvider"))
	self._activePlayersService = serviceBag:GetService(require("ActivePlayersServiceClient"))
	self._root = nil
end

function PlayerTrackerUIService.Start(self)
	local handle = self._screenGuiProvider:Get("PLAYERS_TRACKER")
	handle.IgnoreGuiInset = true
	self._root = ReactRoblox.createRoot(handle)
	self._root:render(React.createElement(playerTrackerContainer, {
		_activePlayersService = self._activePlayersService,
	}))
end

function PlayerTrackerUIService.Destroy(self)
	self._maid:DoCleaning()
end

return PlayerTrackerUIService
