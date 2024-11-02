@tool

extends Node3D

@export var WEAPON_TYPE: Weapons:
	set(value):
		WEAPON_TYPE = value
		if Engine.is_editor_hint():
			load_weapon()

@onready var weapon_mesh: MeshInstance3D = %WeaponMesh
@onready var shadow_mesh: MeshInstance3D = %ShadowMesh

var mouse_movement: Vector2

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
	
func _physics_process(delta: float) -> void:
	sway_weapon(delta)
	
func load_weapon() -> void:
	weapon_mesh.mesh = WEAPON_TYPE.mesh
	shadow_mesh.mesh = WEAPON_TYPE.mesh
	position = WEAPON_TYPE.position
	rotation_degrees = WEAPON_TYPE.rotation
	scale = WEAPON_TYPE.scale
	shadow_mesh.visible = WEAPON_TYPE.shadow
	
func sway_weapon(delta: float) -> void:
	# clamp mouse movement
	mouse_movement = mouse_movement.clamp(WEAPON_TYPE.sway_min, WEAPON_TYPE.sway_max)
	# adjust weapon position using lerp
	position.x = lerp(position.x, WEAPON_TYPE.position.x - mouse_movement.x * WEAPON_TYPE.sway_amount_position * delta, WEAPON_TYPE.sway_speed_position)
	position.y = lerp(position.y, WEAPON_TYPE.position.y + mouse_movement.y * WEAPON_TYPE.sway_amount_position * delta, WEAPON_TYPE.sway_speed_position)
	# adjust weapon rotation using lerp
	rotation_degrees.y = lerp(rotation_degrees.y, WEAPON_TYPE.rotation.y - mouse_movement.x * WEAPON_TYPE.sway_amount_rotation * delta, WEAPON_TYPE.sway_speed_rotation)
	rotation_degrees.x = lerp(rotation_degrees.x, WEAPON_TYPE.rotation.x + mouse_movement.y * WEAPON_TYPE.sway_amount_rotation * delta, WEAPON_TYPE.sway_speed_rotation)
	
