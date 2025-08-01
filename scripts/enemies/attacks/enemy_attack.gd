# This is an abstract class that does mostly nothing.
class_name EnemyAttack extends Node2D

@onready var attack_charge_effect: GPUParticles2D = $AttackChargeEffect


var is_active: bool = false


func _ready() -> void:
	attack_charge_effect.emitting = false


func set_active(active: bool) -> void:
	is_active = active


func init() -> void:
	pass # implemented by inheritors
