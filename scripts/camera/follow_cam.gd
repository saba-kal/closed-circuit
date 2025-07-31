extends Camera2D

@export var follow_target: Node2D


func _process(delta: float) -> void:
	if is_instance_valid(follow_target):
		global_position = follow_target.global_position
