local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local require = require(script.Parent.loader).load(script)

local PlayerTrackerUIService = {}
PlayerTrackerUIService.ServiceName = "PlayerTrackerUIService"

local Maid = require("Maid")
local CharacterPromiseUtils = require("CharacterPromiseUtils")
local CharacterUtils = require("CharacterUtils")
local AttributeUtils = require("AttributeUtils")
local PlayerLineUI = require("PlayerLineUI")
local PlayerBoxUI = require("PlayerBoxUI")

local function playerTrackerContainer(props)
	local activePlayers, setActivePlayers = React.useState({})

	React.useEffect(function()
		-- Initialize with existing players
		for _, player in props._activePlayersService.activePlayers:GetList() do
			CharacterPromiseUtils.promiseCharacter(player):Then(function(character: Model)
				setActivePlayers(function(prevActivePlayers)
					local newActivePlayers = table.clone(prevActivePlayers)
					newActivePlayers[player] = {
						character = character,
						characterSize = character:GetExtentsSize(),
						screenPoint = Vector3.new(),
						onScreen = false,
						player = player,
					}
					return newActivePlayers
				end)
			end)
		end

		local addedConnection = props._activePlayersService.activePlayers.ItemAdded:Connect(function(player)
			CharacterPromiseUtils.promiseCharacter(player):Then(function(character: Model)
				setActivePlayers(function(prevActivePlayers)
					local newActivePlayers = table.clone(prevActivePlayers)
					newActivePlayers[player] = {
						character = character,
						screenPoint = Vector3.new(),
						onScreen = false,
						player = player,
					}
					return newActivePlayers
				end)
			end)
		end)
		local removedConnection = props._activePlayersService.activePlayers.ItemRemoved:Connect(function(player)
			setActivePlayers(function(prevActivePlayers)
				local newActivePlayers = table.clone(prevActivePlayers)
				newActivePlayers[player] = nil
				return newActivePlayers
			end)
		end)

		return function()
			addedConnection:Disconnect()
			removedConnection:Disconnect()
		end
	end, {})

	-- Separate useEffect for the PreRender loop to avoid stale closures
	React.useEffect(function()
		local connection = RunService.PreRender:Connect(function()
			-- Use the callback form to get the current state
			setActivePlayers(function(currentActivePlayers)
				if next(currentActivePlayers) == nil then
					return currentActivePlayers -- No players to update
				end

				local newActivePlayers = table.clone(currentActivePlayers)
				for player in currentActivePlayers do
					local rootPart = CharacterUtils.getPlayerRootPart(player)
					if
						not rootPart
						or AttributeUtils.getAttribute(player, "health") <= 0
						or AttributeUtils.getAttribute(Players.LocalPlayer, "health") <= 0
					then
						newActivePlayers[player].screenPoint = Vector3.new()
						newActivePlayers[player].onScreen = false
					else
						local screenPoint: Vector3, onScreen: boolean =
							workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
						newActivePlayers[player].screenPoint = screenPoint
						newActivePlayers[player].onScreen = onScreen
					end
				end
				return newActivePlayers
			end)
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	local children = {}
	for _, data in activePlayers do
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
