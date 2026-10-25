class_name Player
extends CharacterBody2D

const FACING_EPSILON: float = 0.05

@export_group("Ground Movement")
@export_range(0.0, 1000.0, 1.0, "suffix:px/s") var max_run_speed: float = 260.0
@export_range(0.0, 10000.0, 10.0, "suffix:px/s²") var ground_acceleration: float = 2400.0
@export_range(0.0, 10000.0, 10.0, "suffix:px/s²") var ground_friction: float = 2800.0

@export_group("Air Movement")
@export_range(0.0, 1000.0, 1.0, "suffix:px/s") var max_air_speed: float = 300.0
@export_range(0.0, 10000.0, 10.0, "suffix:px/s²") var air_acceleration: float = 1000.0
@export_range(0.0, 10000.0, 10.0, "suffix:px/s²") var air_drag: float = 350.0

@export_group("Jetpack Physics")
@export_range(0.0, 5000.0, 10.0, "suffix:px/s²") var gravity: float = 1400.0
## Must exceed gravity or the jetpack cannot lift the player.
@export_range(0.0, 8000.0, 10.0, "suffix:px/s²") var thrust_acceleration: float = 2600.0
@export_range(0.0, 2000.0, 1.0, "suffix:px/s") var max_rise_speed: float = 380.0
@export_range(0.0, 3000.0, 1.0, "suffix:px/s") var max_fall_speed: float = 800.0

@export_group("Aiming")
## 0 = instant snap. Higher = smoother (exponential smoothing rate).
@export_range(0.0, 60.0, 0.5) var aim_smoothing: float = 0.0

@onready var jetpack: JetpackComponent = %JetpackComponent
@onready var weapon: WeaponComponent = %WeaponComponent
@onready var _input_source: InputSource = %InputSource
@onready var _visuals: Node2D = %Visuals
@onready var _weapon_pivot: Node2D = %WeaponPivot
@onready var _muzzle: Marker2D = %Muzzle
@onready var _thrust_vfx: GPUParticles2D = %ThrustParticles


func _ready() -> void:
	assert(thrust_acceleration > gravity, "Thrust must exceed gravity to lift off.")
	_thrust_vfx.emitting = false
	jetpack.thrust_started.connect(_on_thrust_started)
	jetpack.thrust_stopped.connect(_on_thrust_stopped)


func _physics_process(delta: float) -> void:
	_input_source.poll(_weapon_pivot.global_position)

	var grounded := is_on_floor()
	var thrusting := jetpack.tick(delta, _input_source.thrust_held, grounded)

	_apply_vertical_motion(delta, thrusting)
	_apply_horizontal_motion(delta, grounded)
	move_and_slide()

	_update_aim(delta)

	# Weapon ticks after aiming so the muzzle position matches this frame's pose.
	weapon.tick(
		delta,
		_input_source.fire_held,
		_muzzle.global_position,
		_input_source.aim_direction
	)


# --- Public API (used by weapons / HUD / future network layer) -------------

func get_aim_direction() -> Vector2:
	return _input_source.aim_direction


func get_muzzle_position() -> Vector2:
	return _muzzle.global_position


func is_fire_requested() -> bool:
	return _input_source.fire_held


# --- Motion ----------------------------------------------------------------

func _apply_vertical_motion(delta: float, thrusting: bool) -> void:
	var accel_y := gravity
	if thrusting:
		accel_y -= thrust_acceleration
	velocity.y += accel_y * delta
	velocity.y = clampf(velocity.y, -max_rise_speed, max_fall_speed)


func _apply_horizontal_motion(delta: float, grounded: bool) -> void:
	var axis := _input_source.move_axis
	var top_speed := max_run_speed if grounded else max_air_speed
	var rate: float
	if is_zero_approx(axis):
		rate = ground_friction if grounded else air_drag
	else:
		rate = ground_acceleration if grounded else air_acceleration
	velocity.x = move_toward(velocity.x, axis * top_speed, rate * delta)


# --- Aiming ----------------------------------------------------------------

func _update_aim(delta: float) -> void:
	var target_angle := _input_source.aim_direction.angle()
	if aim_smoothing > 0.0:
		var weight := 1.0 - exp(-aim_smoothing * delta)
		_weapon_pivot.rotation = lerp_angle(_weapon_pivot.rotation, target_angle, weight)
	else:
		_weapon_pivot.rotation = target_angle

	# Derive facing from the pivot's actual angle (with a small hysteresis band
	# around vertical) so flipping stays consistent while smoothing is active.
	var facing_x := cos(_weapon_pivot.rotation)
	if absf(facing_x) > FACING_EPSILON:
		var facing_left := facing_x < 0.0
		_weapon_pivot.scale.y = -1.0 if facing_left else 1.0
		_visuals.scale.x = -1.0 if facing_left else 1.0


# --- Signal handlers -------------------------------------------------------

func _on_thrust_started() -> void:
	_thrust_vfx.emitting = true


func _on_thrust_stopped() -> void:
	_thrust_vfx.emitting = false
