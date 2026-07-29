extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const sens = 0.001

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	#handles the mouse input and camara stuff
	
	if event is InputEventMouseMotion:
		#rotation.y = $Head.rotation.y
		$Head.rotate_y(-event.relative.x*sens)
		$Head/Camera3D.rotate_x(-event.relative.y*sens)

func vault_ray(height):
	
	var space = get_world_3d().direct_space_state

	var start = global_position + Vector3(0,height,0)
	var end = start + $Head.transform.basis.z * -5.0

	var query = PhysicsRayQueryParameters3D.create(start, end)
	query.exclude = [self]

	var result = space.intersect_ray(query)

	if result:
	
		return true
		
	else:
		return false


func _physics_process(delta: float) -> void:

		
		
		
	# Handle spacebar.
	if Input.is_action_just_pressed("ui_accept"):
			
		print("Spacebar pressed: ")
		
		
		
		var jump_possible = false
		
		var feet_ray = vault_ray(-1)
		var midbody_ray = vault_ray(0)
		
		if feet_ray and not midbody_ray:
			print("Vault = True")
		else:
			print("Vault = False")
		
		if is_on_floor():
			jump_possible = true
			print("Jump = True")
		else:
			print("Jump = False")
			
		
		
		
		#final spacebar decsion
		print("______________")

		if jump_possible:
			print("Outcome = Jump")
			velocity.y = JUMP_VELOCITY
		
		else:
			print("Outcome = Nothing")
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var input_dir := Input.get_vector("Left","Right", "Forward", "Back")	
	
	var direction : Vector3 = ($Head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
 	
	
		# Add the gravity. 
		#different movement rules for being on the ground or not
	if not is_on_floor():
		velocity += get_gravity() * delta
		
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


	move_and_slide()
