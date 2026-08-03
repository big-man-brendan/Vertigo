extends Node3D

var rolling = false
var old_rotation = 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if rolling:
		rotation.x -= 0.2

		if abs(rotation.x - old_rotation) >= 2 * PI:
			rotation.x = old_rotation
			rolling = false

func _on_character_body_3d_roll() -> void:
	if !rolling:
		old_rotation = rotation.x
		rolling = true
