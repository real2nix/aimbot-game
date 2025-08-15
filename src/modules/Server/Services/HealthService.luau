local RunService = game:GetService("RunService")
local require = require(script.Parent.loader).load(script)

local HealthService = {}
HealthService.ServiceName = "HealthService"

local Maid = require("Maid")

local SECONDS_UNTIL_HEALTH_REGEN = 3
local REGEN_AMOUNT = 10
local SECONDS_BETWEEN_REGENS = 1

function HealthService.Init(self, serviceBag)
	-- Private
	self._maid = Maid.new()
	self._gunService = serviceBag:GetService(require("GunService"))
	self._activePlayersService = serviceBag:GetService(require("ActivePlayersService"))

	self._userIdsHealMaids = {}

	-- Public
end

function HealthService.Start(self)
	self._maid:Add(self._gunService.playerHitSignal:Connect(function(data)
		if self._userIdsHealMaids[data.playerHit.UserId] then
			self._userIdsHealMaids[data.playerHit.UserId]:DoCleaning()
			self._userIdsHealMaids[data.playerHit.UserId] = nil
		end
		local healMaid = Maid.new()
		self._userIdsHealMaids[data.playerHit.UserId] = healMaid
		healMaid:Add(task.delay(SECONDS_UNTIL_HEALTH_REGEN, function()
			local secondsSinceLastRegen = 0
			healMaid:Add(RunService.PreRender:Connect(function(deltaTime)
				secondsSinceLastRegen += deltaTime
				if secondsSinceLastRegen < SECONDS_BETWEEN_REGENS then
					return
				end
				secondsSinceLastRegen = 0
				local currentHealth = self._activePlayersService.activePlayers[data.playerHit].health.Value
				if currentHealth >= 150 then
					if self._userIdsHealMaids[data.playerHit.UserId] then
						self._userIdsHealMaids[data.playerHit.UserId]:DoCleaning()
						self._userIdsHealMaids[data.playerHit.UserId] = nil
					end
					return
				end
				local newHealth = math.min(currentHealth + REGEN_AMOUNT, 150)
				self._activePlayersService.activePlayers[data.playerHit].health.Value = newHealth
			end))
		end))
	end))
end

function HealthService.Destroy(self)
	self._maid:DoCleaning()
end

return HealthService
