class_name RandomlyRotatingTarget extends Node2D

@export var rotation_speed = 1

@onready var target: Node2D = $Marker2D

var target_rotation: float = 0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	target_rotation = rng.randf_range(0, 2 * PI)
	await get_tree().physics_frame
	var player: Player = get_tree().get_first_node_in_group("player")
	reparent(player, false)


func _process(delta: float) -> void:
	rotation = rotate_toward(rotation, target_rotation, rotation_speed * delta)
	if abs(angle_difference(rotation, target_rotation)) < 0.1:
		target_rotation = rng.randf_range(0, 2 * PI)
