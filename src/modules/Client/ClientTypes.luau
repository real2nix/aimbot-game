local require = require(script.Parent.loader).load(script)

local _ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local Signal = require("Signal")
local Promise = require("Promise")
local ValueObject = require("ValueObject")
local ObservableSet = require("ObservableSet")
local ObservableList = require("ObservableList")
local GenericScreenGuiProvider = require("GenericScreenGuiProvider")

export type ActivePlayersServiceClient = {
	_maid: Maid.Maid,
	_serviceBag: _ServiceBag.ServiceBag,
	_remoteEventPromise: Promise.Promise<RemoteEvent>,
	activePlayers: ObservableSet.ObservableSet<Player>,
	playerObjects: { [Player]: any }, -- PlayerClassClient
}

export type AimbotServiceClient = {
	_maid: Maid.Maid,
	_aimbotMaid: Maid.Maid,
	_gunServiceClient: GunServiceClient,
	_activePlayersServiceClient: ActivePlayersServiceClient,
	_params: RaycastParams,
	_getClosestPlayer: (self: AimbotServiceClient) -> Player?,
}

export type AmmoUIClient = {
	_maid: Maid.Maid,
	_screenGuiProvider: ScreenGuiProvider,
	_gunServiceClient: GunServiceClient,
}

export type CrosshairServiceClient = {
	_maid: Maid.Maid,
	_screenGuiProvider: ScreenGuiProvider,
	crosshairEnabled: ValueObject.ValueObject<boolean>,
}

export type DamageDirectionIndicatorServiceClient = {
	_maid: Maid.Maid,
	_serviceBag: _ServiceBag.ServiceBag,
}

export type DeathServiceClient = {
	_maid: Maid.Maid,
	_serviceBag: _ServiceBag.ServiceBag,
	_crosshairServiceClient: CrosshairServiceClient,
	clientDiedSignal: Signal.Signal<()>,
}

export type EliminationServiceClient = {
	_maid: Maid.Maid,
	_gunServiceClient: GunServiceClient,
	_screenGuiProvider: ScreenGuiProvider,
	_eliminationsObservableList: ObservableList.ObservableList<string>,
}

export type EnvironmentSoundsServiceClient = {
	_maid: Maid.Maid,
}

export type GunModelControllerClient = {
	_maid: Maid.Maid,
}

export type GunServiceClient = {
	_maid: Maid.Maid,
	_serviceBag: _ServiceBag.ServiceBag,
	_aimbotServiceClient: AimbotServiceClient,
	_remoteEventPromise: Promise.Promise<RemoteEvent>,

	state: ValueObject.ValueObject<string>,
	maxAmmo: ValueObject.ValueObject<number>,
	ammo: ValueObject.ValueObject<number>,
	reloadSeconds: ValueObject.ValueObject<number>,
	shootCooldownSeconds: ValueObject.ValueObject<number>,
	damagePerBullet: ValueObject.ValueObject<number>,

	reloadSignal: Signal.Signal<()>,
	playerHitSignal: Signal.Signal<any>,
	objectHitSignal: Signal.Signal<any>,

	_startShooting: (self: GunServiceClient) -> (),
	_reload: (self: GunServiceClient) -> (),
	_shoot: (self: GunServiceClient) -> (),
}

export type HealthServiceClient = {
	_maid: Maid.Maid,
	_screenGuiProvider: ScreenGuiProvider,
	_crosshairServiceClient: CrosshairServiceClient,
	_deathServiceClient: DeathServiceClient,
	health: ValueObject.ValueObject<number>,
}

export type HitmarkerServiceClient = {
	_maid: Maid.Maid,
	_serviceBag: _ServiceBag.ServiceBag,
	_gunServiceClient: GunServiceClient,
}

export type InputTypeServiceClient = {
	_maid: Maid.Maid,
	_serviceBag: _ServiceBag.ServiceBag,
}

export type ObjectHitServiceClient = {
	_maid: Maid.Maid,
	_serviceBag: _ServiceBag.ServiceBag,
	_gunServiceClient: GunServiceClient,
}

export type ReloadUIClient = {
	_maid: Maid.Maid,
	_screenGuiProvider: ScreenGuiProvider,
	_gunServiceClient: GunServiceClient,
	_countValue: ValueObject.ValueObject<number>,
}

export type ScreenGuiProvider = typeof(setmetatable({} :: {}, {} :: typeof({ __index = GenericScreenGuiProvider })))

-- [[ Client Class Types ]]

export type DamageDirectionIndicatorUIClient = {
	_maid: Maid.Maid,
	_screenGuiProvider: ScreenGuiProvider,
	_angleDegrees: ValueObject.ValueObject<number>,
}

export type DamageMarkerClient = {
	_maid: Maid.Maid,
	_gunServiceClient: GunServiceClient,
	_highlightServiceClient: any,
	_animatedHighlightModel: any,
}

export type HitmarkerUIClient = {
	_maid: Maid.Maid,
	_screenGuiProvider: ScreenGuiProvider,
}

export type ObjectHitParticlesClient = {
	_maid: Maid.Maid,
}

export type PlayerClassClient = {
	_maid: Maid.Maid,
	_highlightServiceClient: any,
	_screenGuiProvider: ScreenGuiProvider,
	_forcefieldObject: any?,
}

return {}
