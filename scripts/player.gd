class_name Player extends CharacterBody3D

@export_range(0.01, 1, 0.01) var MOUSE_SENSITIVITY: float = 0.5
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var toggle_sprint: bool = true
@export var crouch_toggle: bool = true
@export var always_uncrouch_out_of_slide: bool = true

@onready var camera_controller: Node3D = $CameraController
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var stair_step: ShapeCast3D = $StairStep
@onready var block_stairs: ShapeCast3D = $BlockStairs

const STAIR_JUMP: float = 2
const STAIR_DECAY: float = 0.25

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var direction: Vector3
var _mouse_rotation: Vector2
var _rotation_input: float
var _tilt_input: float
var _player_rotation : Vector3
var _camera_rotation : Vector3

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.player = self
	stair_step.add_exception(self)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _physics_process(delta: float) -> void:
	update_camera(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
		
func update_camera(delta: float):
	
	# Rotates camera using euler rotation
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0,_mouse_rotation.y,0.0)
	_camera_rotation = Vector3(_mouse_rotation.x,0.0,0.0)

	camera_controller.transform.basis = Basis.from_euler(_camera_rotation)
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	camera_controller.rotation.z = 0.0

	_rotation_input = 0.0
	_tilt_input = 0.0

func update_gravity(delta: float) -> void:
	velocity.y -= gravity * delta
	
func update_input():
	# get input direction and calculate move direction
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

func update_velocity(speed: float, acceleration: float, deceleration: float) -> void:
	if direction:
		if stair_step.is_colliding() and not block_stairs.is_colliding():
			velocity.y = lerp(STAIR_JUMP, 0.0, STAIR_DECAY)
			#print("step hit")
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)
		velocity.z = move_toward(velocity.z, 0, deceleration)
	move_and_slide()
