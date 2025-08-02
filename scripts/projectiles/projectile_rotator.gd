extends Node2D


@export var rotation_speed: float = 1
@export var time_until_projectile_can_damage: float = 2


var child_projectiles: Array[Projectile]
var time_since_start: float = 0


func _ready() -> void:
	for child in get_children():
		if child is Projectile:
			child.can_damage = false # Give player time to react
			child_projectiles.append(child)


func _process(delta: float) -> void:
	rotate(delta * rotation_speed)
	for projectile in child_projectiles:
		projectile.global_rotation = 0
		if time_since_start >= time_until_projectile_can_damage:
			projectile.can_damage = true
	modulate.a = min((max(time_since_start - 1, 0)) / time_until_projectile_can_damage, 1)
	time_since_start += delta
