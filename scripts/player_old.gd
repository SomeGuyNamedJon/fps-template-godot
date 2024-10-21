extends CharacterBody3D

@export_range(1, 10, 0.1) var DEFAULT_SPEED: float = 5.0
@export_range(5, 20, 0.1) var SPRINT_SPEED: float = 7.0
@export_range(1, 10, 0.1) var JUMP_VELOCITY: float = 4.5
#@export_range(1, 10, 0.1) var CROUCH_SLOWDOWN: float = 2.0
@export_range(0.1, 1, 0.05) var ACCELERATION: float = 0.1
@export_range(0.1, 1, 0.05) var DECELERATION: float = 0.25
@export_range(0.01, 0.1, 0.01) var MOUSE_SENSITIVITY: float = 0.05
#@export_range(5, 10, 0.1) var CROUCH_SPEED: float = 7.0
#@export var CROUCH_TOGGLE: bool = false

@onready var camera_controller: Node3D = $CameraController
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shape_cast_3d: ShapeCast3D = $ShapeCast3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var _speed = DEFAULT_SPEED

# crouch vars
var _is_crouching: bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.player = self

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
	#if event.is_action_pressed("crouch"):
		#toggle_crouch()	

func _physics_process(delta: float) -> void:
	# check if grounded, if not apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	# jump code
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
	
	# get input direction and calculate move direction
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (camera_controller.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# slow speed if crouching
	#_speed = DEFAULT_SPEED if not _is_crouching else DEFAULT_SPEED / CROUCH_SLOWDOWN

	# calculate velocity
	if direction:
		velocity.x = lerp(velocity.x, direction.x * _speed, ACCELERATION)
		velocity.z = lerp(velocity.z, direction.z * _speed, ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION)
		velocity.z = move_toward(velocity.z, 0, DECELERATION)
	
	# if crouch toggle set, uncrouch when crouch key released
	#if CROUCH_TOGGLE:
		#if Input.is_action_just_released("crouch") and _is_crouching:
			#toggle_crouch()
	
	# call move_and_slide()	
	move_and_slide()
	
	#Global.debug.add_property("SPEED", speed)
	#Global.debug.add_property("VELOCITY", velocity)
	
func _unhandled_input(event: InputEvent) -> void:
	# move the camera towards direction of mouse movement
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_controller.rotation.x -= event.relative.y * MOUSE_SENSITIVITY
		camera_controller.rotation_degrees.x = clamp(camera_controller.rotation_degrees.x, -90.0, 90.0)
		camera_controller.rotation.y -= event.relative.x * MOUSE_SENSITIVITY
		
#func toggle_crouch() -> void:
	#if _is_crouching:
		#if not shape_cast_3d.is_colliding():
			#animation_player.play("crouch", -1, -CROUCH_SPEED, true)
			#_is_crouching = false
		#elif CROUCH_TOGGLE:
			#await get_tree().create_timer(0.1).timeout
			#toggle_crouch()
	#else:
		#animation_player.play("crouch", -1, CROUCH_SPEED)
		#_is_crouching = true
