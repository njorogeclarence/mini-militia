class_name Projectile
extends Node2D
## Pooled bullet. Instead of an Area2D (which can tunnel through thin
## colliders at high speed), each physics tick sweeps a ray from the old
## position to the new one, so hits are reliable at any speed.

signal expired(projectile: Projectile)

const TRACER_LENGTH: float = 18.0
const TRACER_COLOR: Color = Color(1.0, 0.85, 0.3)

var _velocity: Vector2 = Vector2.ZERO
var _damage: float = 0.0
var _distance_left: float = 0.0
var _hit_mask: int = 0


func _ready() -> void:
	_set_active(false)


func _draw() -> void:
	draw_line(Vector2(-TRACER_LENGTH, 0.0), Vector2.ZERO, TRACER_COLOR, 3.0)


func launch(origin: Vector2, direction: Vector2, data: WeaponData, hit_mask: int) -> void:
	global_position = origin
	rotation = direction.angle()
	_velocity = direction * data.projectile_speed
	_damage = data.damage
	_distance_left = data.max_range
	_hit_mask = hit_mask
	_set_active(true)


func _physics_process(delta: float) -> void:
	var from := global_position
	var step := _velocity * delta

	var query := PhysicsRayQueryParameters2D.create(from, from + step, _hit_mask)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var hit: Dictionary = get_world_2d().direct_space_state.intersect_ray(query)

	if not hit.is_empty():
		global_position = hit["position"]
		var collider: Object = hit["collider"]
		if collider is Hurtbox:
			(collider as Hurtbox).receive_hit(_damage, _velocity.normalized())
		_retire()
		return

	global_position = from + step
	_distance_left -= step.length()
	if _distance_left <= 0.0:
		_retire()


func _retire() -> void:
	_set_active(false)
	expired.emit(self)


func _set_active(value: bool) -> void:
	visible = value
	set_physics_process(value)
