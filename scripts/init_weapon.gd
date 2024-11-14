@tool

class_name WeaponController extends Node3D

@export var WEAPON_TYPE: Weapons:
	set(value):
		WEAPON_TYPE = value
		if Engine.is_editor_hint():
			load_weapon()
			
@export var sway_noise: NoiseTexture2D
@export var sway_speed: float = 1.2
@export var reset: bool = false:
	set(value):
		reset = value
		if Engine.is_editor_hint():
			load_weapon()

@onready var weapon_mesh: MeshInstance3D = %WeaponMesh
@onready var shadow_mesh: MeshInstance3D = %ShadowMesh

var mouse_movement: Vector2
var random_sway: Vector2
var time: float = 0.0

func _ready() -> void:
	load_weapon()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon1"):
		WEAPON_TYPE = preload("res://assets/weapons/crowbar/crowbar_left.tres")
		load_weapon()
	if event.is_action_pressed("weapon2"):
		WEAPON_TYPE = preload("res://assets/weapons/crowbar/crowbar_right.tres")
		load_weapon()
	if event is InputEventMouseMotion:
		mouse_movement = event.relative
	
func load_weapon() -> void:
	weapon_mesh.mesh = WEAPON_TYPE.mesh
	shadow_mesh.mesh = WEAPON_TYPE.mesh
	position = WEAPON_TYPE.position
	rotation_degrees = WEAPON_TYPE.rotation
	scale = WEAPON_TYPE.scale
	shadow_mesh.visible = WEAPON_TYPE.shadow
	
func sway_weapon(delta: float, isIdle: bool) -> void:
	### Mouse movement sway
	# clamp mouse movement
	mouse_movement = mouse_movement.clamp(WEAPON_TYPE.sway_min, WEAPON_TYPE.sway_max)
	
	if isIdle:
		### Random sway
		var sway_random: float = get_sway_noise()
		var sway_random_adjusted: float = sway_random * WEAPON_TYPE.idle_sway_adjustment
		# update time using delta and prepare our two random sway values using sine waves
		time += delta * (sway_speed + sway_random)
		random_sway.x = sin(time * 1.5 + sway_random_adjusted) / WEAPON_TYPE.random_sway_amount
		random_sway.y = sin(time - sway_random_adjusted) / WEAPON_TYPE.random_sway_amount
	else:
		random_sway = Vector2.ZERO
	
	### Apply sway to weapon
	# adjust weapon position using lerp
	position.x = lerp(position.x, WEAPON_TYPE.position.x - (mouse_movement.x * WEAPON_TYPE.sway_amount_position + random_sway.x) * delta, WEAPON_TYPE.sway_speed_position)
	position.y = lerp(position.y, WEAPON_TYPE.position.y + (mouse_movement.y * WEAPON_TYPE.sway_amount_position + random_sway.y) * delta, WEAPON_TYPE.sway_speed_position)
	# adjust weapon rotation using lerp
	rotation_degrees.y = lerp(rotation_degrees.y, WEAPON_TYPE.rotation.y - (mouse_movement.x * WEAPON_TYPE.sway_amount_rotation + (random_sway.y * WEAPON_TYPE.idle_sway_rotation_strength)) * delta, WEAPON_TYPE.sway_speed_rotation)
	rotation_degrees.x = lerp(rotation_degrees.x, WEAPON_TYPE.rotation.x + (mouse_movement.y * WEAPON_TYPE.sway_amount_rotation + (random_sway.x * WEAPON_TYPE.idle_sway_rotation_strength)) * delta, WEAPON_TYPE.sway_speed_rotation)
	
func get_sway_noise() -> float:
	var player_position: Vector3 = Vector3.ZERO
	# only access global var in game to avoid warnings
	if not Engine.is_editor_hint():
		player_position = Global.player.global_position
	# return noise value based on player position
	return sway_noise.noise.get_noise_2d(player_position.x, player_position.y)
