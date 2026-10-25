class_name WeaponComponent
extends Node
## Owns weapon state: cooldown, ammo, reload. The owner calls tick() every
## physics frame (call-down), and anyone can listen to the signals (signal-up).

signal fired
signal ammo_changed(current: int, magazine: int)
signal reload_started(duration: float)
signal reload_finished
signal weapon_changed(data: WeaponData)

@export var weapon_data: WeaponData
## Physics layers this weapon's bullets collide with.
## Default 5 = layer 1 (world) + layer 3 (enemy).
@export_flags_2d_physics var target_mask: int = 5

var ammo: int = 0
var is_reloading: bool = false

var _pool: ProjectilePool
var _cooldown: float = 0.0
var _reload_left: float = 0.0
var _trigger_was_held: bool = false
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	equip(weapon_data)


## Dependency injection: the level hands the weapon its projectile pool.
func setup(pool: ProjectilePool) -> void:
	_pool = pool


func equip(data: WeaponData) -> void:
	assert(data != null, "WeaponComponent needs a WeaponData resource.")
	weapon_data = data
	ammo = data.magazine_size
	is_reloading = false
	_reload_left = 0.0
	_cooldown = 0.0
	weapon_changed.emit(data)
	ammo_changed.emit(ammo, data.magazine_size)


func tick(delta: float, wants_fire: bool, muzzle_position: Vector2, aim_direction: Vector2) -> void:
	_cooldown = maxf(_cooldown - delta, 0.0)

	if is_reloading:
		_reload_left -= delta
		if _reload_left <= 0.0:
			_finish_reload()

	var trigger_pulled := wants_fire and (weapon_data.automatic or not _trigger_was_held)
	_trigger_was_held = wants_fire

	if not trigger_pulled or is_reloading or _cooldown > 0.0:
		return
	if ammo <= 0:
		start_reload()
		return
	_fire(muzzle_position, aim_direction)


func start_reload() -> void:
	if is_reloading or ammo >= weapon_data.magazine_size:
		return
	is_reloading = true
	_reload_left = weapon_data.reload_time
	reload_started.emit(weapon_data.reload_time)


func _fire(muzzle_position: Vector2, aim_direction: Vector2) -> void:
	if _pool == null:
		push_warning("WeaponComponent has no ProjectilePool; call setup() first.")
		return

	var base_angle := aim_direction.angle()
	var half_spread := deg_to_rad(weapon_data.spread_degrees) * 0.5
	for _i in weapon_data.pellets_per_shot:
		var angle := base_angle + _rng.randf_range(-half_spread, half_spread)
		_pool.spawn(muzzle_position, Vector2.from_angle(angle), weapon_data, target_mask)

	ammo -= 1
	_cooldown = 1.0 / weapon_data.fire_rate
	fired.emit()
	ammo_changed.emit(ammo, weapon_data.magazine_size)

	if ammo == 0:
		start_reload()


func _finish_reload() -> void:
	is_reloading = false
	ammo = weapon_data.magazine_size
	ammo_changed.emit(ammo, weapon_data.magazine_size)
	reload_finished.emit()
