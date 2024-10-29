class_name FallingPlayerState extends PlayerMovementState
@export var SPEED: float = 5.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var DOUBLE_JUMP_VELOCITY: float = 4.5
@export var double_jump_toggle: bool = true

var double_jump: bool = false
var is_crouched: bool = false
var next_state: String

func enter(previous_state: State) -> void:
	animation_player.pause()
	if previous_state.name == "CrouchingPlayerState":
		is_crouched = true
	elif previous_state.name == "JumpingPlayerState":
		is_crouched = previous_state.is_crouched
			
	if is_crouched:
		next_state = "CrouchingPlayerState"
	else:
		next_state = default_state
	
func update(delta: float) -> void:
	player.update_gravity(delta)
	player.update_velocity(SPEED, ACCELERATION, DECELERATION)
	
	if not double_jump and Input.is_action_just_pressed("jump") and double_jump_toggle:
		player.velocity.y += DOUBLE_JUMP_VELOCITY
		double_jump = true
		animation_player.play("jump_start")
		
	if player.is_on_floor():
		animation_player.play("jump_end")
		transition.emit(next_state)
	
func exit() -> void:
	double_jump = false
	is_crouched = false
