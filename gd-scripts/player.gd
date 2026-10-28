extends CharacterBody3D
class_name Player

@export var mouse_sensetivity: float = 0.001
@onready var neck: Node3D = $Neck
@onready var head: Node3D = $Neck/Head
@onready var camera: Camera3D = $Neck/Head/Camera3D
@onready var look_ray: RayCast3D = $Neck/Head/RayCast3D

const WALK_SPEED := 5.0
const SPRINT_SPEED := 10.0
var speed := WALK_SPEED
const JUMP_VELOCITY = 7
var flying := true
var third_person := false
const THIRD_PERSON_CAM_DIST: float = 15.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and not flying:
		velocity += get_gravity() * delta
	elif flying:
		velocity.y = 0

	# Handle jump.
	if Input.is_action_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("ToggleFly"):
		flying = not flying
	if Input.is_action_pressed("Sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	
	if flying:
		if Input.is_action_pressed("Rise"):
			velocity.y = speed
		if Input.is_action_pressed("Sink"):
			velocity.y = - speed
	
	if Input.is_action_just_pressed("ChangeCameraPerspective"):
		third_person = not third_person
		if third_person:
			camera.position.z = THIRD_PERSON_CAM_DIST
		else:
			camera.position.z = 0
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	var direction := (neck.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var relative = event.relative * mouse_sensetivity
		neck.rotate_y(-relative.x)
		head.rotate_x(-relative.y)
		head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)

func get_target_pos() -> Vector3:
	return look_ray.get_collision_point()
