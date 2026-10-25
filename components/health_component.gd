class_name HealthComponent
extends Node
## Reusable health state. Knows nothing about who owns it or how damage
## arrives; Hurtbox (or anything else) calls take_damage().

signal health_changed(current: float, maximum: float)
signal damaged(amount: float)
signal healed(amount: float)
signal died

@export var max_health: float = 100.0

var current: float
var is_dead: bool = false


func _ready() -> void:
	current = max_health


func take_damage(amount: float) -> void:
	if is_dead or amount <= 0.0:
		return
	current = maxf(current - amount, 0.0)
	damaged.emit(amount)
	health_changed.emit(current, max_health)
	if current == 0.0:
		is_dead = true
		died.emit()


func heal(amount: float) -> void:
	if is_dead or amount <= 0.0:
		return
	var before := current
	current = minf(current + amount, max_health)
	if not is_equal_approx(before, current):
		healed.emit(current - before)
		health_changed.emit(current, max_health)


## Restores full health and clears the dead state (respawn).
func reset() -> void:
	is_dead = false
	current = max_health
	health_changed.emit(current, max_health)
