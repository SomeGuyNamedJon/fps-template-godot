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
@onready var camera: Camera3D = %Camera3D

var mouse_movement: Vector2
var random_sway: Vector2
var bob_amount: Vector2 = Vector2.ZERO
var time: float = 0.0

var bullet_hole = preload("res://scenes/bullet_hole.tscn")

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
	
	### Apply sway and bob to weapon
	# adjust weapon position using lerp
	position.x = lerp(position.x, WEAPON_TYPE.position.x - (mouse_movement.x * WEAPON_TYPE.sway_amount_position + random_sway.x + bob_amount.x) * delta, WEAPON_TYPE.sway_speed_position)
	position.y = lerp(position.y, WEAPON_TYPE.position.y + (mouse_movement.y * WEAPON_TYPE.sway_amount_position + random_sway.y + bob_amount.y) * delta, WEAPON_TYPE.sway_speed_position)
	# adjust weapon rotation using lerp
	rotation_degrees.y = lerp(rotation_degrees.y, WEAPON_TYPE.rotation.y - (mouse_movement.x * WEAPON_TYPE.sway_amount_rotation + (random_sway.y * WEAPON_TYPE.idle_sway_rotation_strength)) * delta, WEAPON_TYPE.sway_speed_rotation)
	rotation_degrees.x = lerp(rotation_degrees.x, WEAPON_TYPE.rotation.x + (mouse_movement.y * WEAPON_TYPE.sway_amount_rotation + (random_sway.x * WEAPON_TYPE.idle_sway_rotation_strength)) * delta, WEAPON_TYPE.sway_speed_rotation)

func weapon_bob(delta: float, bob_speed: float, hbob: float, vbob: float) -> void:
	time += delta
	bob_amount.x = sin(time * bob_speed) * hbob
	bob_amount.y = abs(cos(time * bob_speed) * vbob)

func get_sway_noise() -> float:
	var player_position: Vector3 = Vector3.ZERO
	# only access global var in game to avoid warnings
	if not Engine.is_editor_hint():
		player_position = Global.player.global_position
	# return noise value based on player position
	return sway_noise.noise.get_noise_2d(player_position.x, player_position.y)
	
func attack() -> void:
	var space_state = camera.get_world_3d().direct_space_state
	var screen_center = get_viewport().size / 2
	var origin = camera.project_ray_origin(screen_center)
	var end = origin + camera.project_ray_normal(screen_center) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)
	
	if result:
		spawn_decal(result.get("position"), result.get("normal"))
	
func spawn_decal(position: Vector3, normal: Vector3) -> void:
	var instance = bullet_hole.instantiate()
	var fade = get_tree().create_tween()
	
	# spawn decal
	get_tree().root.add_child(instance)
	instance.global_position = position
	instance.look_at(instance.global_transform.origin + normal, Vector3.UP)
	if normal != Vector3.UP and normal != Vector3.DOWN:
		instance.rotate_object_local(Vector3(1,0,0), 90)
	
	# fade decal
	await get_tree().create_timer(2).timeout
	fade.tween_property(instance, "modulate:a", 0, 1.5)
	await get_tree().create_timer(1.5).timeout
	instance.queue_free()
