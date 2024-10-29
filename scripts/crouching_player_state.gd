class_name CrouchingPlayerState extends PlayerMovementState

@export var SPEED: float = 3.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export_range(1, 6, 0.1) var CROUCH_SPEED: float = 4.0

@onready var shape_cast_3d: ShapeCast3D = $"../../ShapeCast3D"

func enter(previous_state: State) -> void:
	animation_player.speed_scale = 1.0
	if previous_state.name != "SlidingPlayerState" and previous_state.name != "FallingPlayerState":
		animation_player.play("crouch", -1.0, CROUCH_SPEED)
	elif previous_state.name == "SlidingPlayerState" or previous_state.name == "FallingPlayerState":
		await animation_player.animation_finished
		animation_player.current_animation = "crouch"
		animation_player.seek(1.0, true)
		if player.always_uncrouch_out_of_slide:
			uncrouch(default_state)
	
func update(delta: float) -> void:
	player.update_gravity(delta)
	player.update_input()
	player.update_velocity(SPEED, ACCELERATION, DECELERATION)
	
	if player.velocity.y < -3.0 and not player.is_on_floor():
		transition.emit("FallingPlayerState")
	
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		transition.emit("JumpingPlayerState")
		
	if Input.is_action_just_pressed("sprint") and player.is_on_floor():
		uncrouch("SprintingPlayerState")
	
	if (Input.is_action_just_released("crouch") or not Input.is_action_pressed("crouch")) and !player.crouch_toggle \
		or Input.is_action_just_pressed("crouch") and player.crouch_toggle:
		if player.velocity.length() == 0:
			uncrouch(default_state)
		else:
			uncrouch("WalkingPlayerState")
		
func uncrouch(next_state: String) -> void:
	if not shape_cast_3d.is_colliding() and (not Input.is_action_pressed("crouch") or player.crouch_toggle):
		animation_player.play("crouch", -1.0, -CROUCH_SPEED * 1.5, true)
		if animation_player.is_playing():
			await animation_player.animation_finished
		transition.emit(next_state)
	elif shape_cast_3d.is_colliding() and !player.crouch_toggle:
		await get_tree().create_timer(0.1).timeout
		uncrouch(next_state)
