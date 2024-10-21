class_name WalkingPlayerState extends PlayerMovementState

@export var SPEED: float = 5.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var TOP_ANIM_SPEED: float = 2.2

func enter(_previous_state: State) -> void:
	animation_player.play("walking", -1.0, 1.0)
	
func exit() -> void:
	animation_player.speed_scale = 1.0

func update(delta: float) -> void:
	set_animation_speed(player.velocity.length(), SPEED, TOP_ANIM_SPEED)
	player.update_gravity(delta)
	player.update_input()
	player.update_velocity(SPEED, ACCELERATION, DECELERATION)
	
	if player.velocity.length() == 0.0:
		transition.emit("IdlePlayerState")
		
	if Input.is_action_just_pressed("sprint") and player.is_on_floor():
		transition.emit("SprintingPlayerState")
		
	if Input.is_action_just_pressed("crouch") and player.is_on_floor():
		transition.emit("CrouchingPlayerState")



	
