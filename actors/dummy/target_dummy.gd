class_name TargetDummy
extends Node2D
## Stationary practice target. Flashes on hit and respawns after dying so you
## can keep testing weapons.

const ENEMY_LAYER: int = 4  # physics layer 3 (bit value 4)

@export var respawn_delay: float = 1.5

@onready var _health: HealthComponent = %HealthComponent
@onready var _hurtbox: Hurtbox = %Hurtbox
@onready var _sprite: Sprite2D = %Sprite
@onready var _label: Label = %HealthLabel

var _base_color: Color
var _flash_tween: Tween


func _ready() -> void:
	_base_color = _sprite.modulate
	_health.health_changed.connect(_on_health_changed)
	_health.died.connect(_on_died)
	_hurtbox.hit_received.connect(_on_hit_received)
	_on_health_changed(_health.current, _health.max_health)


func _on_health_changed(current: float, maximum: float) -> void:
	_label.text = "%d / %d" % [ceili(current), int(maximum)]


func _on_hit_received(_damage: float, _direction: Vector2) -> void:
	if _health.is_dead:
		return
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	_sprite.modulate = Color.WHITE
	_flash_tween = create_tween()
	_flash_tween.tween_property(_sprite, "modulate", _base_color, 0.12)


func _on_died() -> void:
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	_hurtbox.set_deferred("collision_layer", 0)
	_sprite.modulate = Color(0.3, 0.3, 0.3, 0.6)
	_label.text = "DOWN"
	await get_tree().create_timer(respawn_delay).timeout
	_revive()


func _revive() -> void:
	_hurtbox.collision_layer = ENEMY_LAYER
	_sprite.modulate = _base_color
	_health.reset()
