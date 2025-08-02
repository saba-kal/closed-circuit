extends Node2D


@export var rotation_speed: float = 1

var child_projectiles: Array[Projectile]


func _ready() -> void:
	for child in get_children():
		if child is Projectile:
			child_projectiles.append(child)


func _process(delta: float) -> void:
	rotate(delta * rotation_speed)
	for projectile in child_projectiles:
		projectile.global_rotation = 0
