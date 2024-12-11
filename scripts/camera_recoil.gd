extends Node3D

@export var recoil_amount: Vector2
@export var snap_amount: float
@export var speed: float

@onready var weapon: WeaponController = %Weapon

var current_rotation: Vector3
var target_rotation: Vector3

func _ready() -> void:
	weapon.weapon_fired.connect(add_recoil)

func _process(delta: float) -> void:
	target_rotation = lerp(target_rotation, Vector3.ZERO, speed * delta)
	current_rotation = lerp(current_rotation, target_rotation, snap_amount * delta)
	basis = Quaternion.from_euler(current_rotation)
	
func add_recoil() -> void:
	var x = randf_range(0, recoil_amount.x)
	var y = randf_range(-recoil_amount.y, recoil_amount.y)
	target_rotation += Vector3(x,y,0)
