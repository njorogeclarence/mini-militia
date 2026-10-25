class_name JetpackComponent
extends Node
## Owns fuel state and thrust eligibility. Does NOT touch velocity; the
## owning body decides what thrust means physically.

signal fuel_changed(current: float, maximum: float)
signal thrust_started
signal thrust_stopped
signal fuel_depleted
signal fuel_restored

@export_group("Fuel")
@export var max_fuel: float = 100.0
@export var drain_per_second: float = 40.0
@export var regen_per_second: float = 50.0
## Seconds after thrust stops before regeneration begins.
@export var regen_delay: float = 0.6
## After running dry, fuel must reach this level before thrust re-ignites.
## Prevents stuttering on/off at near-empty.
@export var relight_threshold: float = 15.0
@export var regen_while_airborne: bool = false

var fuel: float
var is_thrusting: bool = false
var is_locked_out: bool = false

var _regen_timer: float = 0.0


func _ready() -> void:
	fuel = max_fuel
	fuel_changed.emit(fuel, max_fuel)


## Advances fuel simulation. Returns true if thrust is active this tick.
func tick(delta: float, wants_thrust: bool, grounded: bool) -> bool:
	var previous_fuel := fuel
	var can_thrust := wants_thrust and not is_locked_out and fuel > 0.0

	if can_thrust:
		fuel = maxf(fuel - drain_per_second * delta, 0.0)
		_regen_timer = regen_delay
		if fuel == 0.0:
			is_locked_out = true
			fuel_depleted.emit()
	else:
		_regen_timer = maxf(_regen_timer - delta, 0.0)
		if _regen_timer == 0.0 and (grounded or regen_while_airborne):
			fuel = minf(fuel + regen_per_second * delta, max_fuel)
		if is_locked_out and fuel >= relight_threshold:
			is_locked_out = false
			fuel_restored.emit()

	_set_thrusting(can_thrust)

	if not is_equal_approx(previous_fuel, fuel):
		fuel_changed.emit(fuel, max_fuel)
	return can_thrust


## For pickups.
func refuel(amount: float) -> void:
	fuel = minf(fuel + amount, max_fuel)
	fuel_changed.emit(fuel, max_fuel)


func _set_thrusting(value: bool) -> void:
	if value == is_thrusting:
		return
	is_thrusting = value
	if value:
		thrust_started.emit()
	else:
		thrust_stopped.emit()
