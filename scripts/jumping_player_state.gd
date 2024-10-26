class_name JumpingPlayerState extends PlayerMovementState
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var JUMP_VELOCITY: float = 4.5
var entering_speed: float
var is_crouched: float = false

func enter(previous_state: State) -> void:
	player.velocity.y += JUMP_VELOCITY
	entering_speed = player.velocity.length()
	
	if previous_state.name == "SlidingPlayerState":
		animation_player.play("RESET")
		await animation_player.animation_finished
		
	if previous_state.name == "CrouchingPlayerState":
		is_crouched = true
	else:
		is_crouched = false
	
	animation_player.play("jump_start")
		
func update(delta: float) -> void:
	player.update_gravity(delta)
	player.update_velocity(entering_speed, ACCELERATION, DECELERATION)
		
	if Input.is_action_just_released("jump"):
		if player.velocity.y > 0:
			player.velocity.y = player.velocity.y / 2
			
	if player.is_on_floor():
		animation_player.play("jump_end")
		transition.emit(default_state)
			
	if player.velocity.y < -0.1 and not player.is_on_floor():
		transition.emit("FallingPlayerState")
