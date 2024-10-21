class_name SlidingPlayerState extends PlayerMovementState

@export var SPEED: float = 6.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var TILT_AMOUNT: float = 0.09
@export_range(1, 6, 0.1) var SLIDE_ANIM_SPEED: float = 4.0

@onready var shape_cast_3d: ShapeCast3D = $"../../ShapeCast3D"

func enter(_previous_state: State) -> void:
	set_tilt(player.rotation.y)
	animation_player.get_animation("slide").track_set_key_value(6, 0, player.velocity.length() + SPEED)
	animation_player.speed_scale = 1.0
	animation_player.play("slide", -1.0, SLIDE_ANIM_SPEED)	
	
func update(delta: float) -> void:
	player.update_gravity(delta)
	player.update_velocity(SPEED, ACCELERATION, DECELERATION)
	
func set_tilt(player_rotation: float) -> void:
	var tilt = Vector3.ZERO
	tilt.z = clamp(TILT_AMOUNT * player_rotation, -0.1, 0.1)
	if tilt.z == 0.0:
		tilt.z = 0.05
	animation_player.get_animation("slide").track_set_key_value(3,1,tilt)
	animation_player.get_animation("slide").track_set_key_value(3,2,tilt)
	
func finish() -> void:
	if Input.is_action_pressed("sprint"):
		transition.emit("SprintingPlayerState")
	else:
		transition.emit("CrouchingPlayerState")
