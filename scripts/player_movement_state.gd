class_name PlayerMovementState extends State

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
var player: Player

func _ready() -> void:
	await owner.ready
	player = owner as Player
	
func set_animation_speed(speed: float, max_speed: float, top_speed: float) -> void:
	var alpha = remap(speed, 0.0, max_speed, 0.0, 1.0)
	animation_player.speed_scale = lerp(0.0, top_speed, alpha)
