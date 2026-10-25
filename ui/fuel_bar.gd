class_name FuelBar
extends ProgressBar


func bind(jetpack: JetpackComponent) -> void:
	jetpack.fuel_changed.connect(_on_fuel_changed)
	_on_fuel_changed(jetpack.fuel, jetpack.max_fuel)


func _on_fuel_changed(current: float, maximum: float) -> void:
	max_value = maximum
	value = current
