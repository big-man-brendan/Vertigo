extends Node3D

#had to move this code back and forth between the buffer and the head beacuse of rotation issues
const roll_speed = 0.2
var rolling = false
var roll_amount = 0.0
var start_rotation = 0.0
var vaulting = false
var vault_timer = 0
func _process(delta: float) -> void:
	
	if rolling:
		
		#super tuff remap to link the amount we rolled to a good sin wave 
		# w desmos
		var dip_amount = remap(roll_amount,0,-6.4,0,-PI)
		
		position.y = sin(dip_amount)
		
		
		#print(position.y)
		
		rotation.x -= roll_speed
		roll_amount -= roll_speed
		print(roll_amount,'|',dip_amount)
		
		if roll_amount <= -(2 * PI):
			
			rolling = false
			roll_amount = 0.0
	
	elif vaulting:
		
		vault_timer += delta
		
		var vault_duration = 0.6
		var t = vault_timer / vault_duration
		
		if t < 1.0:
			rotation.x = -sin(t * PI) * deg_to_rad(8)
		else:
			rotation.x = 0.0
			vaulting = false
			vault_timer = 0.0
		
		
func _on_character_body_3d_roll() -> void:
	if !rolling:
		#start_rotation = rotation.x
		roll_amount = 0.0
		rolling = true


func _on_character_body_3d_vault() -> void:
	
	vaulting = true
	
