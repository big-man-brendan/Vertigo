extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const sens = 0.001

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		#rotation.y = $Head.rotation.y
		$Head.rotate_y(-event.relative.x*sens)
		$Head/Camera3D.rotate_x(-event.relative.y*sens)

func _physics_process(delta: float) -> void:

		
		
		
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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
