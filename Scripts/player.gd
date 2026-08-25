extends CharacterBody3D


#test commit from pc

#Constants
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const sens = 0.001

#Signals

signal roll

#Variabals

var new_pos = Vector3.ZERO
var frames_since_vaultstart = 0
var last_vault_cast = 0
var old_y_velocity = 0
var bob_timer = 0

#Player state

var rolling = false
var vaulting = false
var wall_running = false
var wall_side = "left"

#node references

@onready var player_camara = $Head/Buffer/Camera3D
@onready var right_hand = $Head/Buffer/Camera3D/right_hand
@onready var buffer = $Head/Buffer
@onready var player_head = $Head



func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	#handles the mouse input and camara stuff
	
	if event is InputEventMouseMotion:
		#rotation.y = $Head.rotation.y
		player_head.rotate_y(-event.relative.x*sens)
		player_camara.rotate_x(-event.relative.y*sens)
	
	#clamp it using because godot loves radians
	player_camara.rotation.x = clamp(player_camara.rotation.x,-1.5,1.5)
	
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
	var end = start + player_head.transform.basis.z * -3.0

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

func wall_ray():
	
	
	
	#Casts a ray out both sides, like 90 degres on both sides
	
	var space = get_world_3d().direct_space_state

	var start = global_position + Vector3(0, 0, 0)
	
	var end : Vector3 = start + (player_head.transform.basis * Vector3(1, 0, 0)) * 2
	
	
	
	#var head_rotation = $Head.rotation.y
	
	
	var query = PhysicsRayQueryParameters3D.create(start, end)
	query.exclude = [self]
	
	var right_result = space.intersect_ray(query)
	
	
	
	
	
	end = start + (player_head.transform.basis * Vector3(-1, 0, 0)) * 2
	
	#var head_rotation = $Head.rotation.y
	
	
	query = PhysicsRayQueryParameters3D.create(start, end)
	query.exclude = [self]
	
	var left_result = space.intersect_ray(query)
	
	if wall_running == false:
	
		if left_result:
			wall_running = true
			wall_side = "left"
			print("left wallrun:",left_result)
			
		elif right_result:
			wall_running = true
			wall_side = "right"
			print("right wallrun:",right_result)
		
		else:
			pass
	
	else:
		if wall_side == "right":
			return right_result
		
		elif wall_side == "left":
			return left_result
			
			

func handle_jump():
		
		
		
		
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


		if wall_running:
			wall_running = false
		
		if is_on_floor():
			jump_possible = true
			print("Jump = True")
			
		else:
			print("Jump = False")
			
			
			#See if we can wall run. gotta love the boiler plate code
			#take the direction, add 90 degresss, send out ray, then -90 degrees, cast ray. 
			#depends on which ray hits, which ever one, attach to wall. 
			
			
			var facing_direction = player_camara.rotation.y
			
			wall_ray()
			
		
		
		#final spacebar decsion
		print("______________")
		

		
		elif vault_possible:
			#Adds hight untill we are above the obstecal, then resets so we
			#know how high we have to go then we can lerp
			
			#and we also gotta check if we cant vault over and then back down like a normal vault
			
			if not vaulting:
				
				var lastray = Vector3.ZERO
				var start_pos = position
				
				
				while true:
					
					
					var ray_end =  0
					var ray_bool = true
					
					#a little work around to return 2 things back. 
					#and i gotta force it to be an array or else
					#godot thinks it might not be and crashes my program. 
					var packed_data: Array = vault_ray(-1,true)
				
					
					ray_end = packed_data[1]
					ray_bool = packed_data[0]
					
					if not ray_bool:
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
	

func handle_bob(delta):
	
	if is_on_floor():
		
		if velocity.length() > 0.1:
			#make a custom timer to prevent bobbing snapping from place to place
			#16.667 is the frame time at 60 fps
			bob_timer += delta + 16.667 
			
			var head_bob = 0.306 + sin(bob_timer / 1000.0 * 13) * 0.05
		
			buffer.position.y = head_bob
			
			#Dont set the rotation, instead we need to add the rotation to it.
			
			buffer.rotation.x += sin(bob_timer / 1000.0 * 12) * 0.003
			buffer.rotation.z += sin(bob_timer / 1000.0 * 7) * 0.001
		
			var bob_amount = 0.05
			var bob_speed = 8.0
		
		
			var bob = sin(bob_timer / 1000.0 * bob_speed) * bob_amount
			
			right_hand.rotation.x = bob * 2

func _physics_process(delta: float) -> void:

	# Handle spacebar.
	# It checks all the different actions that can happen when space is pressed
	# And only does one of them, with debug because code is difficualt
	
	
	if Input.is_action_just_pressed("ui_accept"):
		handle_jump()
	
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

	
	var input_dir = Vector3.ZERO
	
	if not vaulting:
		
		input_dir = Input.get_vector("Left","Right", "Forward", "Back")
	

	var direction : Vector3 = (player_head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	
	handle_bob(delta)
	
	
	if wall_running:
		velocity.y = 0
		
		
		#Check if we are still on the wall
		
		var wall_check = wall_ray()
	
		if !wall_check:
			wall_running = false
		
		
		# Add the gravity. 
		#different movement rules for being on the ground or not
	if not is_on_floor():

		if not vaulting and not wall_running:
			
			
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
		
		if Input.is_action_pressed("Shift"):
			
			emit_signal("roll")
	
	
	
	
	move_and_slide()
