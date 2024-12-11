extends Node3D

@export var recoil_amount: Vector3
@export var max_recoil: Vector3
@export var snap_amount: float
@export var speed: float

@onready var weapon: WeaponController = $".."

var current_position: Vector3
var target_position: Vector3

func _ready() -> void:
	weapon.weapon_fired.connect(add_recoil)

func _process(delta: float) -> void:
	target_position = lerp(target_position, Vector3.ZERO, speed * delta)
	current_position = lerp(current_position, target_position, snap_amount * delta)
	position = current_position
	
func add_recoil() -> void:
	var x = randf_range(0, recoil_amount.x)
	var y = randf_range(0, recoil_amount.y)
	var z = randf_range(-recoil_amount.z, recoil_amount.z)
	target_position += Vector3(x,y,z)
	target_position = target_position.clamp(-max_recoil, max_recoil)
