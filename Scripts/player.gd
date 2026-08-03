extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const sens = 0.001
var vaulting = false
var new_pos = Vector3.ZERO
var frames_since_vaultstart = 0
var last_vault_cast = 0
var old_y_velocity = 0

signal roll

var rolling = false
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	#handles the mouse input and camara stuff
	
	if event is InputEventMouseMotion:
		#rotation.y = $Head.rotation.y
		$Head.rotate_y(-event.relative.x*sens)
		$Head/Camera3D.rotate_x(-event.relative.y*sens)

func floor_ray():
	
	var space = get_world_3d().direct_space_state

	var start = global_position
	var end = start + Vector3(0,-1.2,0)

	var query = PhysicsRayQueryParameters3D.create(start, end)
	query.exclude = [self]

	var result = space.intersect_ray(query)

	if result:
	
		return true
		
	else:
		return false

func vault_ray(height, output):
	
	#Mostly boilerplate but it just casts a ray and returns extra data if i want it
	
	var space = get_world_3d().direct_space_state

	var start = global_position + Vector3(0, height, 0)
	var end = start + $Head.transform.basis.z * -2.0

	var query = PhysicsRayQueryParameters3D.create(start, end)
	query.exclude = [self]

	var result = space.intersect_ray(query)

	if result:
		
		if output:
			return [true, result.position]
		else:
			return true
	
	if output:
		return [false, Vector3.ZERO]
	
	else:
		return false



func _physics_process(delta: float) -> void:

	
	
	
	# Handle spacebar.
	# It checks all the different actions that can happen when space is pressed
	# And only does one of them, with debug because code is difficualt
	if Input.is_action_just_pressed("ui_accept"):
			
		print("Spacebar pressed: ")
		
		
		
		var jump_possible = false
		
		var feet_ray = vault_ray(-1,false)
		var midbody_ray = vault_ray(0,false)
		
		var vault_possible = false
		
		if feet_ray and not midbody_ray and velocity.length() > 1:
			print("Vault = True")
			vault_possible = true
		else:
			print("Vault = False")
		
		
		
		if is_on_floor():
			jump_possible = true
			print("Jump = True")
		else:
			print("Jump = False")
			
		
		
		
		#final spacebar decsion
		print("______________")
		
		if vault_possible:
			#Adds hight untill we are above the obstecal, then resets so we
			#know how high we have to go then we can lerp
			
			if not vaulting:
				
				var lastray = Vector3.ZERO
				var start_pos = position
				
				
				while true:
					
					
					var ray_end =  0
					var ray_bool = true
					
					#a little work around to return 2 things back. 
					#and i gotta force it to be an array or else
					#godot thinks it might not be and crashes my program 		
					var packed_data: Array = vault_ray(-1,true)
				
					
					ray_end = packed_data[1]
					ray_bool = packed_data[0]
					
					if  not ray_bool:
						new_pos = last_vault_cast + Vector3(0,1.1,0)
						
						vaulting = true
						position = start_pos
						vaulting = true
						break
					
					else:
						position.y += 0.1
						last_vault_cast = ray_end
					
					#while vault_ray(-1,false) == true:
						#
						#position.y += 0.1
					#
					#new_pos = global_position + Vector3(0, 0,0) + $Head.transform.basis.z * -2.0
					#
					#vaulting = true
					#
					#position = start_pos
				
		elif jump_possible:
			print("Outcome = Jump")
			velocity.y = JUMP_VELOCITY
		
		else:
			print("Outcome = Nothing")
	
	
	
	if vaulting:
		
		#So you dont get stuck hopefully
		frames_since_vaultstart += 1
		
		if position.distance_to(new_pos) < 0.1 or frames_since_vaultstart > 30:
			frames_since_vaultstart = 0
			vaulting = false
			print("finshed vault")
		
		
		
		position = position.move_toward(new_pos,0.3)
		
	
	
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	var input_dir := Input.get_vector("Left","Right", "Forward", "Back")
	
	#if vaulting == true:
	#	input_dir = Vector2(input_dir.x,-1)

	
	var direction : Vector3 = ($Head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	
	
	
	#Add some hand movement :)
	
	var hands = $Head/Camera3D/right_hand
	
	var bob_amount = 0.05
	var bob_speed = 8.0
	
	
	var movement = velocity.length()
	
	
	#if vaulting:
		
	if movement > 0:
		var bob = sin(Time.get_ticks_msec() / 1000.0 * bob_speed) * bob_amount
		
		hands.rotation.x = bob * 2
		

	
	
		# Add the gravity. 
		#different movement rules for being on the ground or not
	if not is_on_floor():
		
		
		
		
		
		
		if not vaulting:
			
			
			old_y_velocity = velocity.y
			
			
			
			velocity += get_gravity() * delta
		#velocity += get_gravity() * delta

		
		if direction:
			#velocity.x = (direction.x * SPEED)
			#velocity.z = (direction.z * SPEED)
			velocity.x = move_toward(velocity.x, direction.x*SPEED, SPEED/20)
			velocity.z = move_toward(velocity.z, direction.z*SPEED, SPEED/20)
			
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED/20)
			velocity.z = move_toward(velocity.z, 0, SPEED/20)

	else:
		if direction:
			velocity.x = (direction.x * SPEED)
			velocity.z = (direction.z * SPEED)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED/3)
			velocity.z = move_toward(velocity.z, 0, SPEED/3)

	
	
	
	
	if old_y_velocity < -10:
		old_y_velocity = 0
		print("You gotta roll")
		if Input.is_action_pressed("Shift"):
			print("roll")
			emit_signal("roll")
		
	
	
	move_and_slide()
