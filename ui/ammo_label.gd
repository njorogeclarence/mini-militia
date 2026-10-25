class_name AmmoLabel
extends Label

var _weapon: WeaponComponent


func bind(weapon: WeaponComponent) -> void:
	_weapon = weapon
	weapon.ammo_changed.connect(_on_state_changed.unbind(2))
	weapon.reload_started.connect(_on_state_changed.unbind(1))
	weapon.reload_finished.connect(_on_state_changed)
	weapon.weapon_changed.connect(_on_state_changed.unbind(1))
	_refresh()


func _on_state_changed() -> void:
	_refresh()


func _refresh() -> void:
	var data := _weapon.weapon_data
	if _weapon.is_reloading:
		text = "%s   RELOADING..." % data.display_name
	else:
		text = "%s   %d / %d" % [data.display_name, _weapon.ammo, data.magazine_size]
