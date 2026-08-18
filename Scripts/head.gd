extends Node3D

#had to move this code back and forth between the buffer and the head beacuse of rotation issues

var rolling = false
var roll_amount = 0.0
var start_rotation = 0.0

func _process(delta: float) -> void:
	if rolling:
		var roll_speed = 0.2
		
		rotation.x -= roll_speed
		roll_amount += roll_speed
		
		if roll_amount >= 2 * PI:
			rotation.x = start_rotation
			rolling = false
			roll_amount = 0.0

func _on_character_body_3d_roll() -> void:
	if !rolling:
		start_rotation = rotation.x
		roll_amount = 0.0
		rolling = true
