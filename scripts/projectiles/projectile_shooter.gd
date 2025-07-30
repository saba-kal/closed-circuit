class_name ProjectileShooter extends Node2D

@export var projectile_scene: PackedScene
@export var projectile_speed: float = 500
@export var projectile_damage: int = 1
@export var time_between_shots: float = 0.25
@export var shoot_direction: Vector2 = Vector2.UP
@export_range(1, 16) var projectile_count: int = 1
@export var angle_between_projectiles: float = 15.0

var time_since_last_shot: float = 10
var is_active: bool = false


func _process(delta: float) -> void:
	if is_active && time_since_last_shot >= time_between_shots:
		shoot()
		time_since_last_shot = 0
	else:
		time_since_last_shot += delta


func shoot() -> void:
	var total_cone_angle: float = (projectile_count - 1) * angle_between_projectiles
	var start_angle: float = - total_cone_angle / 2.0
	for i in range(projectile_count):
		var current_angle: float = start_angle + i * angle_between_projectiles
		var direction: Vector2 = shoot_direction.rotated(deg_to_rad(current_angle))
		var projectile: Projectile = projectile_scene.instantiate()
		projectile.speed = projectile_speed
		projectile.damage = projectile_damage
		projectile.direction = direction
		get_tree().current_scene.add_child(projectile)
		projectile.global_position = global_position


func set_active(active: bool) -> void:
	time_since_last_shot = 0
	is_active = active
