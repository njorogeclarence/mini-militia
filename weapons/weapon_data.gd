class_name WeaponData
extends Resource
## Pure data describing a weapon. Create new weapons as .tres files in the
## editor (right-click > New Resource > WeaponData); no code changes needed.

@export var display_name: String = "Weapon"

@export_group("Damage")
@export var damage: float = 10.0
@export_range(1, 20) var pellets_per_shot: int = 1
@export_range(0.0, 45.0, 0.5, "suffix:deg") var spread_degrees: float = 1.5

@export_group("Fire Control")
@export_range(0.1, 30.0, 0.1, "suffix:shots/s") var fire_rate: float = 8.0
## false = semi-auto: one shot per trigger pull.
@export var automatic: bool = true

@export_group("Ammo")
@export var magazine_size: int = 30
@export var reload_time: float = 1.6

@export_group("Projectile")
@export_range(100.0, 5000.0, 10.0, "suffix:px/s") var projectile_speed: float = 1600.0
@export_range(50.0, 5000.0, 10.0, "suffix:px") var max_range: float = 900.0
