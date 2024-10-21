extends CenterContainer

@onready var player: CharacterBody3D = $"../.."
@onready var top_line: Line2D = $Top
@onready var right_line: Line2D = $Right
@onready var bottom_line: Line2D = $Bottom
@onready var left_line: Line2D = $Left

@export_range(0.05, 1, 0.05) var RETICLE_SPEED: float = 0.25
@export_range(1, 5, 0.5) var RETICLE_DISTANCE: float = 2.0
@export_range(0.1, 2, 0.1) var DOT_RADIUS: float = 1.0
@export var DOT_COLOR: Color = Color.WHITE

func _ready() -> void:
	queue_redraw()
	

func _process(_delta: float) -> void:
	var vel = player.get_real_velocity()
	var speed = Vector3.ZERO.distance_to(vel)
	top_line.position = lerp(top_line.position, Vector2(0, -speed * RETICLE_DISTANCE), RETICLE_SPEED)
	right_line.position = lerp(right_line.position, Vector2(speed * RETICLE_DISTANCE, 0), RETICLE_SPEED)
	bottom_line.position = lerp(bottom_line.position, Vector2(0, speed * RETICLE_DISTANCE), RETICLE_SPEED)
	left_line.position = lerp(left_line.position, Vector2(-speed * RETICLE_DISTANCE, 0), RETICLE_SPEED)

func _draw() -> void:
	draw_circle(Vector2.ZERO, DOT_RADIUS, DOT_COLOR)
