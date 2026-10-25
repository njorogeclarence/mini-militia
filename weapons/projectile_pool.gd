class_name ProjectilePool
extends Node
## Recycles Projectile nodes instead of instantiating/freeing one per shot.
## Place one in the level (at the world origin, outside any moving actor) so
## bullets live in world space and don't inherit the shooter's movement.

@export var projectile_scene: PackedScene
@export_range(0, 256) var prewarm_count: int = 32

var _available: Array[Projectile] = []


func _ready() -> void:
	assert(projectile_scene != null, "ProjectilePool needs a projectile_scene.")
	for _i in prewarm_count:
		_available.append(_create())


func spawn(origin: Vector2, direction: Vector2, data: WeaponData, hit_mask: int) -> Projectile:
	var projectile: Projectile
	if _available.is_empty():
		projectile = _create()  # Pool grows on demand rather than dropping shots.
	else:
		projectile = _available.pop_back()
	projectile.launch(origin, direction, data, hit_mask)
	return projectile


func _create() -> Projectile:
	var projectile := projectile_scene.instantiate() as Projectile
	add_child(projectile)
	projectile.expired.connect(_on_projectile_expired)
	return projectile


func _on_projectile_expired(projectile: Projectile) -> void:
	_available.append(projectile)
