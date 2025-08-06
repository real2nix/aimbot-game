local require = require(script.Parent.loader).load(script)

local _ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local Signal = require("Signal")
local Promise = require("Promise")
local AttributeValue = require("AttributeValue")

export type ActivePlayersService = {
	_maid: Maid.Maid,
	_serviceBag: _ServiceBag.ServiceBag,
	_remoteEvent: RemoteEvent,
	activePlayers: { [Player]: PlayerClass },
	playerAdded: Signal.Signal<Player>,
	playerRemoved: Signal.Signal<Player>,
}

export type DamageDirectionIndicatorService = {
	_maid: Maid.Maid,
	_gunService: GunService,
	_remoteEvent: RemoteEvent,
}

export type DeathService = {
	_maid: Maid.Maid,
	_activePlayersService: ActivePlayersService,
	_gunService: GunService,
	playerDiedSignal: Signal.Signal<Player>,
}

export type GunService = {
	_maid: Maid.Maid,
	_activePlayersService: ActivePlayersService,
	_remoteEventPromise: Promise.Promise<RemoteEvent>,
	playerHitSignal: Signal.Signal<any>,
}

export type SpawnPlayerService = {
	_maid: Maid.Maid,
	_serviceBag: _ServiceBag.ServiceBag,
	_deathService: DeathService,
	_activePlayersService: ActivePlayersService,
	_addForcefield: (self: SpawnPlayerService, Player) -> (),
}

--[[ Server Classes ]]

export type PlayerClass = {
	_maid: Maid.Maid,
	_player: Player,
	forcefield: boolean,
	health: AttributeValue.AttributeValue<number>,
}

return {}
