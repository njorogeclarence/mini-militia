extends Node2D

@onready var _player: Player = $Player
@onready var _fuel_bar: FuelBar = $HUD/FuelBar


func _ready() -> void:
	_fuel_bar.bind(_player.jetpack)
