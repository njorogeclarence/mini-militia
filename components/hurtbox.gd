class_name Hurtbox
extends Area2D
## The "can be hit" region of an actor. Projectiles find this via raycast and
## call receive_hit(); the hurtbox forwards damage to a HealthComponent.
## Set the Area2D collision LAYER to the actor's team layer, MASK to 0.

signal hit_received(damage: float, direction: Vector2)

@export var health: HealthComponent
@export var damage_multiplier: float = 1.0


func _ready() -> void:
	monitoring = false


func receive_hit(damage: float, direction: Vector2) -> void:
	if health != null:
		health.take_damage(damage * damage_multiplier)
	hit_received.emit(damage, direction)
