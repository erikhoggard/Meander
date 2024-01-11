extends CharacterBody3D

# player nodes
@onready var head = $head
@onready var standing_collision_shape = $standing_collision_shape
@onready var crouching_collision_shape = $crouching_collision_shape
@onready var ray_cast_3d = $RayCast3D

@export var mouse_sens = 0.4

var current_speed = 5.0
var direction = Vector3.ZERO
var is_tracking_camera = true

@export var WALKING_SPEED = 5.0
@export var SPRINTING_SPEED = 8.0
const CROUCHING_SPEED = 3.0
const CROUCHING_DEPTH = -0.5
const JUMP_VELOCITY = 4.5
const LERP_SPEED = 10.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	is_tracking_camera = true

func _input(event):
	if event is InputEventMouseMotion and is_tracking_camera:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta):
	
	if Input.is_action_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		is_tracking_camera = false
	elif Input.is_action_pressed("lmb"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		is_tracking_camera = true

	# movement state management
	if Input.is_action_pressed("crouch"):
		current_speed = CROUCHING_SPEED
		head.position.y = lerp(head.position.y, 1.8 + CROUCHING_DEPTH, delta*LERP_SPEED)
		standing_collision_shape.disabled = true 
		crouching_collision_shape.disabled = false 
	elif !ray_cast_3d.is_colliding():	
		standing_collision_shape.disabled = false 
		crouching_collision_shape.disabled = true 
		head.position.y = lerp(head.position.y, 1.8, delta*LERP_SPEED)

		if Input.is_action_pressed("sprint"):
			current_speed = SPRINTING_SPEED
		else:
			current_speed = WALKING_SPEED

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(
		direction, 
		(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), 
		delta*LERP_SPEED
	)
	
	if direction:
		velocity.x = direction.x * current_speed 
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
