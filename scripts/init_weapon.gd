@tool

extends Node3D

@export var WEAPON_TYPE: Weapons:
	set(value):
		WEAPON_TYPE = value
		if Engine.is_editor_hint():
			load_weapon()

@onready var weapon_mesh: MeshInstance3D = %WeaponMesh
@onready var shadow_mesh: MeshInstance3D = %ShadowMesh

func _ready() -> void:
	load_weapon()
	
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("weapon1"):
		#WEAPON_TYPE = preload("res://assets/weapons/crowbar/crowbar_left.tres")
		#load_weapon()
	#if event.is_action_pressed("weapon2"):
		#WEAPON_TYPE = preload("res://assets/weapons/crowbar/crowbar_right.tres")
		#load_weapon()
	
func load_weapon() -> void:
	weapon_mesh.mesh = WEAPON_TYPE.mesh
	shadow_mesh.mesh = WEAPON_TYPE.mesh
	position = WEAPON_TYPE.position
	rotation_degrees = WEAPON_TYPE.rotation
	scale = WEAPON_TYPE.scale
	shadow_mesh.visible = WEAPON_TYPE.shadow
