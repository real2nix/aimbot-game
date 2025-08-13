local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local React = require(ReplicatedStorage.Packages.React)

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local PlayerThumbnailUtils = require("PlayerThumbnailUtils")

return function(props)
	-- connect to event, listen to see if it changes
	local kills, setKills = React.useState(props._playersScoreServiceClient.playersScores[props.player].Value)
	local image, setImage = React.useState("")
	local layoutOrder, setLayoutOrder = React.useState(0)

	React.useEffect(function()
		local maid = Maid.new()
		maid:Add(props._playersScoreServiceClient.playersScores[props.player].Changed:Connect(function(value)
			setKills(value)
		end))

		maid:Add(props._playersScoreServiceClient.scoreUpdatedSignal:Connect(function()
			local tbl = {}
			for player, scoreValueObject in props._playersScoreServiceClient.playersScores do
				table.insert(tbl, { player = player, score = scoreValueObject.Value })
			end
			table.sort(tbl, function(a, b)
				return a.score > b.score
			end)
			for i, data in tbl do
				if data.player == props.player then
					setLayoutOrder(i)
				end
			end
		end))
		return function()
			maid:DoCleaning()
		end
	end, {})

	React.useEffect(function()
		if RunService:IsStudio() then
			PlayerThumbnailUtils.promiseUserThumbnail(
				33295715,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size100x100
			)
				:Then(function(url)
					setImage(url)
				end)
		else
			PlayerThumbnailUtils.promiseUserThumbnail(
				props.player.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size100x100
			)
				:Then(function(url)
					setImage(url)
				end)
		end
	end, {})

	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		LayoutOrder = layoutOrder,
	}, {
		React.createElement("ImageLabel", {
			Image = image,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}),
		React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.2, 0.2),
			TextScaled = true,
			Text = kills,
			Size = UDim2.fromScale(0.45, 0.45),
			Font = Enum.Font.GothamBlack,
			BackgroundTransparency = 1,
		}, {
			React.createElement("UIStroke", {
				Color = Color3.fromRGB(255, 255, 255),
				Thickness = 2,
			}),
		}),
		React.createElement("UIAspectRatioConstraint"),
		React.createElement("UICorner", { CornerRadius = UDim.new(0.2, 0) }),
	})
end
