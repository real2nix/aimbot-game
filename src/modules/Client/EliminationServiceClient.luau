local require = require(script.Parent.loader).load(script)

local EliminationServiceClient = {}
EliminationServiceClient.ServiceName = "EliminationServiceClient"

local _ServiceBag = require("ServiceBag")
local ClientTypes = require("ClientTypes")
local GunServiceClient = require("GunServiceClient")
local ScreenGuiProvider = require("ScreenGuiProvider")
local Maid = require("Maid")
local AttributeUtils = require("AttributeUtils")
local Blend = require("Blend")
local ObservableList = require("ObservableList")
local Promise = require("Promise")
local RxBrioUtils = require("RxBrioUtils")

function EliminationServiceClient.Init(self: ClientTypes.EliminationServiceClient, serviceBag: _ServiceBag.ServiceBag)
	self._maid = Maid.new()

	self._gunServiceClient = serviceBag:GetService(GunServiceClient)
	self._screenGuiProvider = serviceBag:GetService(ScreenGuiProvider)
	self._eliminationsObservableList = ObservableList.new()
end

function EliminationServiceClient.Start(self: ClientTypes.EliminationServiceClient)
	self._maid:Add(self._gunServiceClient.playerHitSignal:Connect(function(data)
		local health: number = AttributeUtils.getAttribute(data.playerHit, "health", 0)
		if health - self._gunServiceClient.damagePerBullet.Value > 0 then
			return
		end

		-- Register elimination
		local remove = self._eliminationsObservableList:Add(data.playerHit.Name)
		Promise.delay(3, function()
			remove()
		end)
	end))

	local screenGui: ScreenGui = self._maid:Add(self._screenGuiProvider:Get("ELIMINATIONS"))
	screenGui.IgnoreGuiInset = true

	self._maid:Add(Blend.New("Frame")({
		Parent = screenGui,
		Position = UDim2.fromScale(0, 1),
		AnchorPoint = Vector2.new(0, 1),
		Size = UDim2.fromScale(1, 0.3),
		BackgroundTransparency = 1,
		Blend.New("UIListLayout")({
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),
		self._eliminationsObservableList:ObserveItemsBrio():Pipe({
			RxBrioUtils.map(function(name)
				return Blend.New("TextLabel")({
					Text = `<font color="#EE0000">Eliminated</font> <font color="#FFFFFF">{name}</font>`,
					Size = UDim2.fromScale(1, 0.1),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					RichText = true,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextScaled = true,
					TextTransparency = 0.1,
					Blend.New("UIStroke")({
						Thickness = 1.5,
						Transparency = 0.8,
					}),
				})
			end),
		}),
	}):Subscribe())
end

function EliminationServiceClient.Destroy(self: ClientTypes.EliminationServiceClient)
	self._maid:DoCleaning()
end

return EliminationServiceClient
