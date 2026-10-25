class_name InputSource
extends Node
## Abstract producer of per-tick player intent. Swap implementations for
## local input, AI bots, or network-replicated input without touching Player.

var move_axis: float = 0.0
var aim_direction: Vector2 = Vector2.RIGHT
var thrust_held: bool = false
var fire_held: bool = false


## Called by the owner once per physics tick, before it consumes the intent.
func poll(_aim_origin: Vector2) -> void:
	pass
