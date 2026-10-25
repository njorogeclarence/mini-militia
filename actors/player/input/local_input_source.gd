class_name LocalInputSource
extends InputSource

@export_range(0.0, 0.9, 0.01) var aim_deadzone: float = 0.25

var _use_gamepad: bool = false


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		_use_gamepad = false
	elif event is InputEventJoypadMotion:
		var motion := event as InputEventJoypadMotion
		if absf(motion.axis_value) > aim_deadzone:
			_use_gamepad = true
	elif event is InputEventJoypadButton:
		_use_gamepad = true


func poll(aim_origin: Vector2) -> void:
	move_axis = Input.get_axis(&"move_left", &"move_right")
	thrust_held = Input.is_action_pressed(&"thrust")
	fire_held = Input.is_action_pressed(&"fire")

	if _use_gamepad:
		var stick := Input.get_vector(
			&"aim_left", &"aim_right", &"aim_up", &"aim_down", aim_deadzone
		)
		# Retain last aim direction when the stick is released.
		if stick != Vector2.ZERO:
			aim_direction = stick.normalized()
	else:
		var viewport := get_viewport()
		var mouse_world: Vector2 = (
			viewport.get_canvas_transform().affine_inverse()
			* viewport.get_mouse_position()
		)
		var to_mouse := mouse_world - aim_origin
		if to_mouse.length_squared() > 1.0:
			aim_direction = to_mouse.normalized()
