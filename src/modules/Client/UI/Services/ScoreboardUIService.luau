local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local require = require(script.Parent.loader).load(script)

local ScoreboardUIService = {}
ScoreboardUIService.ServiceName = "ScoreboardUIService"

local Maid = require("Maid")
local PlayerKillsUI = require("PlayerKillsUI")

local function scoreboardComponent(props)
	local activePlayers, setActivePlayers = React.useState({})

	React.useEffect(function()
		local maid = Maid.new()
		maid:Add(props._playersScoreServiceClient.playerAdded:Connect(function(player)
			setActivePlayers(function(prev)
				local newPlayers = table.clone(prev)
				newPlayers[player] = true
				return newPlayers
			end)
		end))
		maid:Add(props._playersScoreServiceClient.playerRemoved:Connect(function(player)
			setActivePlayers(function(prev)
				local newPlayers = table.clone(prev)
				newPlayers[player] = nil
				return newPlayers
			end)
		end))
		return function()
			maid:DoCleaning()
		end
	end, {})

	local children = {}
	for player in activePlayers do
		children[player] = React.createElement(PlayerKillsUI, { player })
	end

	return React.createElement("Frame", {
		Position = UDim2.new(0.5, 0, 0, 10),
		Size = UDim2.fromScale(1, 0.05),
		AnchorPoint = Vector2.new(0.5, 0),
	}, children)
end

function ScoreboardUIService.Init(self, serviceBag)
	self._maid = Maid.new()
	self._gunServiceClient = serviceBag:GetService(require("GunServiceClient"))
	self._playersScoreServiceClient = serviceBag:GetService(require("PlayersScoreServiceClient"))
	self._screenGuiProvider = serviceBag:GetService(require("ScreenGuiProvider"))
end

function ScoreboardUIService.Start(self)
	local handle = self._screenGuiProvider:Get("SCOREBOARD")
	handle.IgnoreGuiInset = true
	self._root = ReactRoblox.createRoot(handle)
	self._root:render(React.createElement(scoreboardComponent, {
		_gunServiceClient = self._gunServiceClient,
		_playersScoreServiceClient = self._playersScoreServiceClient,
	}))
end

function ScoreboardUIService.Destroy(self)
	self._maid:DoCleaning()
end

return ScoreboardUIService
