local require = require(script.Parent.loader).load(script)

local PlayerClassClient = {}
PlayerClassClient.ClassName = "PlayerClassClient"
PlayerClassClient.__index = PlayerClassClient

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local _ServiceBag = require("ServiceBag")
local ClientTypes = require("ClientTypes")
local HighlightServiceClient = require("HighlightServiceClient")
local ScreenGuiProvider = require("ScreenGuiProvider")
local Blend = require("Blend")
local Maid = require("Maid")
local CharacterPromiseUtils = require("CharacterPromiseUtils")
local CharacterUtils = require("CharacterUtils")
local AttributeUtils = require("AttributeUtils")
local RxAttributeUtils = require("RxAttributeUtils")
local Rx = require("Rx")

function PlayerClassClient.new(ServiceBag: _ServiceBag.ServiceBag, player): ClientTypes.PlayerClassClient
	local self = setmetatable({}, PlayerClassClient)

	self._maid = Maid.new()
	self._highlightServiceClient = ServiceBag:GetService(HighlightServiceClient)
	self._screenGuiProvider = ServiceBag:GetService(ScreenGuiProvider)
	self._forcefieldObject = nil

	CharacterPromiseUtils.promiseCharacter(player):Then(function(character: Model)
		self._animatedHighlightModel = self._highlightServiceClient:Highlight(character, 1)
		self._animatedHighlightModel:SetHighlightDepthMode(Enum.HighlightDepthMode.AlwaysOnTop)
		self._animatedHighlightModel:SetFillColor(Color3.fromRGB(255, 0, 0))
		self._animatedHighlightModel:SetFillTransparency(0.8)
		self._animatedHighlightModel:SetOutlineTransparency(1)

		local screenGui: ScreenGui = self._maid:Add(self._screenGuiProvider:Get("AIMBOT_LINES"))
		screenGui.IgnoreGuiInset = true

		local screenPointObservable = Rx.fromSignal(RunService.PreRender):Pipe({
			Rx.map(function()
				local rootPart: Part = CharacterUtils.getPlayerRootPart(player)
				if
					not rootPart
					or AttributeUtils.getAttribute(player, "health") <= 0
					or AttributeUtils.getAttribute(Players.LocalPlayer, "health") <= 0
				then
					return {
						screenPoint = Vector3.new(0, 0, 0),
						onScreen = false,
					}
				end
				local screenPoint: Vector3, onScreen: boolean =
					workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
				return {
					screenPoint = screenPoint,
					onScreen = onScreen,
				}
			end),
			Rx.distinct(),
		})

		self._maid:Add(Blend.New("Frame")({
			BackgroundColor3 = Color3.fromRGB(255, 0, 0),
			Name = "Tracker",
			Visible = screenPointObservable:Pipe({
				Rx.map(function(data)
					return data.onScreen
				end),
			}),
			AnchorPoint = Vector2.new(0.5, 0),
			Size = screenPointObservable:Pipe({
				Rx.map(function(data)
					return UDim2.new(
						0,
						(Vector2.new(data.screenPoint.X, data.screenPoint.Y) - Vector2.new(
							workspace.CurrentCamera.ViewportSize.X / 2,
							workspace.CurrentCamera.ViewportSize.Y / 2
						)).Magnitude,
						0,
						1
					)
				end),
			}),
			Position = screenPointObservable:Pipe({
				Rx.map(function(data)
					return UDim2.fromOffset(
						(workspace.CurrentCamera.ViewportSize.X / 2 + data.screenPoint.X) / 2,
						(workspace.CurrentCamera.ViewportSize.Y / 2 + data.screenPoint.Y) / 2
					)
				end),
			}),
			Rotation = screenPointObservable:Pipe({
				Rx.map(function(data)
					local centerX: number = workspace.CurrentCamera.ViewportSize.X / 2
					local centerY: number = workspace.CurrentCamera.ViewportSize.Y / 2

					local dirX: number = data.screenPoint.X - centerX
					local dirY: number = data.screenPoint.Y - centerY

					return math.deg(math.atan2(dirY, dirX))
				end),
			}),
			Parent = screenGui,
		}):Subscribe())

		self._maid:Add(Blend.New("Frame")({
			Parent = screenGui,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = screenPointObservable:Pipe({
				Rx.map(function(data)
					return UDim2.fromOffset(data.screenPoint.X, data.screenPoint.Y)
				end),
			}),
			Visible = screenPointObservable:Pipe({
				Rx.map(function(data)
					return data.onScreen
				end),
			}),
			Size = screenPointObservable:Pipe({
				Rx.map(function()
					local rootPart: Part = CharacterUtils.getPlayerRootPart(player)
					if not rootPart then
						return UDim2.new()
					end
					local characterSize: Vector3 = character:GetExtentsSize()
					local topOffset: Vector3 = rootPart.CFrame.UpVector * characterSize.Y / 2
					local bottomOffset: Vector3 = -rootPart.CFrame.UpVector * characterSize.Y / 2
					local frontOffset: Vector3 = rootPart.CFrame.LookVector * characterSize.Z / 2
					local backOffset: Vector3 = -rootPart.CFrame.LookVector * characterSize.Z / 2
					local rightOffset: Vector3 = rootPart.CFrame.RightVector * characterSize.X / 2
					local leftOffset: Vector3 = -rootPart.CFrame.RightVector * characterSize.X / 2
					local corners3D = {
						rootPart.Position + topOffset + leftOffset + backOffset,
						rootPart.Position + topOffset + rightOffset + backOffset,
						rootPart.Position + topOffset + leftOffset + frontOffset,
						rootPart.Position + topOffset + rightOffset + frontOffset,
						rootPart.Position + bottomOffset + leftOffset + backOffset,
						rootPart.Position + bottomOffset + rightOffset + backOffset,
						rootPart.Position + bottomOffset + leftOffset + frontOffset,
						rootPart.Position + bottomOffset + rightOffset + frontOffset,
					}
					local corners2D = table.create(8)
					for i, corner in ipairs(corners3D) do
						corners2D[i] = workspace.CurrentCamera:WorldToViewportPoint(corner)
					end

					local minX, minY = math.huge, math.huge
					local maxX, maxY = -math.huge, -math.huge
					for _, vec2 in ipairs(corners2D) do
						minX = math.min(minX, vec2.X)
						minY = math.min(minY, vec2.Y)
						maxX = math.max(maxX, vec2.X)
						maxY = math.max(maxY, vec2.Y)
					end
					return UDim2.fromOffset(maxX - minX, maxY - minY)
				end),
			}),
			Blend.New("Frame")({ -- Top
				Size = UDim2.new(1, 0, 0, 2),
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0),
				BackgroundColor3 = Color3.fromRGB(255, 0, 0),
			}),
			Blend.New("Frame")({ -- Bottom
				Size = UDim2.new(1, 0, 0, 2),
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.fromScale(0.5, 1),
				BackgroundColor3 = Color3.fromRGB(255, 0, 0),
			}),
			Blend.New("Frame")({ -- Left
				Size = UDim2.new(0, 2, 1, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 0, 0),
			}),
			Blend.New("Frame")({ -- Right
				Size = UDim2.new(0, 2, 1, 0),
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.fromScale(1, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 0, 0),
			}),
		}):Subscribe())
	end)

	self._maid:Add(player:GetAttributeChangedSignal("health"):Connect(function()
		if player:GetAttribute("health") == 0 then
			if not self._maid._deadHighlight then
				local highlight = self._highlightServiceClient:Highlight(player.Character, 3)
				highlight:SetHighlightDepthMode(Enum.HighlightDepthMode.Occluded)
				highlight:SetFillColor(Color3.fromRGB(255, 255, 255))
				highlight:SetFillTransparency(0)
				highlight:SetOutlineTransparency(1)

				self._maid._deadHighlight = highlight
			end
		else
			self._maid._deadHighlight = nil
		end
	end))

	self._maid:Add(RxAttributeUtils.observeAttribute(player, "forcefield"):Subscribe(function(forcefieldValue: boolean)
		-- animate in if true,
		local transparency: number = if forcefieldValue == true then 0.2 else 1

		-- animate out if false
	end))

	return self
end

function PlayerClassClient.Destroy(self: ClientTypes.PlayerClassClient)
	self._maid:DoCleaning()
end

return PlayerClassClient
