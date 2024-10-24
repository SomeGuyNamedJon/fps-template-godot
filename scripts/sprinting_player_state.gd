class_name SprintingPlayerState extends PlayerMovementState

@export var SPEED = 7.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var TOP_ANIM_SPEED: float = 1.6

func enter(_previous_state: State) -> void:
	animation_player.play("sprint", -1.0, 1.0)
	
func exit() -> void:
	animation_player.speed_scale = 1.0
	
func update(delta: float) -> void:
	set_animation_speed(player.velocity.length(), SPEED, TOP_ANIM_SPEED)
	
	player.update_gravity(delta)
	player.update_input()
	player.update_velocity(SPEED, ACCELERATION, DECELERATION)
	
	if player.toggle_sprint:
		if Input.is_action_just_pressed("sprint"):
			transition.emit("WalkingPlayerState")
	else:
		if Input.is_action_just_released("sprint"):
			transition.emit("WalkingPlayerState")
			
	if player.velocity.length() == 0:
			transition.emit(default_state)
		
	if Input.is_action_just_pressed("crouch"):
		transition.emit("SlidingPlayerState")
		
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		transition.emit("JumpingPlayerState")
	
