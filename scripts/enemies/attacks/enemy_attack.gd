# This is an abstract class that does mostly nothing.
class_name EnemyAttack extends Node2D

var is_active: bool = false


func set_active(active: bool) -> void:
	is_active = active


func init() -> void:
	pass # implemented by inheritors
