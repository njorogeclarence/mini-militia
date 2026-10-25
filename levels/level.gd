extends Node2D
## Composition root: wires dependencies between otherwise decoupled nodes.

@onready var _player: Player = $Player
@onready var _pool: ProjectilePool = $ProjectilePool
@onready var _fuel_bar: FuelBar = $HUD/FuelBar
@onready var _ammo_label: AmmoLabel = $HUD/AmmoLabel


func _ready() -> void:
	_player.weapon.setup(_pool)
	_fuel_bar.bind(_player.jetpack)
	_ammo_label.bind(_player.weapon)
