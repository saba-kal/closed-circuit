class_name ProjectileShooter extends Node2D

signal preparing_to_fire()
signal projectile_fired()

@export var projectile_scene: PackedScene
@export var projectile_speed: float = 500
@export var projectile_damage: int = 1
@export var time_between_shots: float = 0.25
@export var shot_delay: float = 1.0
@export var shoot_direction: Vector2 = Vector2.UP
@export var projectile_lifetime: float = 5.0
@export var spawn_effect: PackedScene
@export_range(1, 16) var projectile_count: int = 1
@export var angle_between_projectiles: float = 15.0

@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound

var time_since_last_shot: float = 10
var is_active: bool = false
var timer: Timer
var is_shooting: bool = false


func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)


func _process(delta: float) -> void:
	if is_ready_to_fire():
		shoot()
		time_since_last_shot = 0
	elif !is_shooting:
		time_since_last_shot += delta


func shoot() -> void:
	is_shooting = true
	timer.start(shot_delay)
	preparing_to_fire.emit()
	await timer.timeout
	shoot_immediately()


func shoot_immediately() -> void:
	var total_cone_angle: float = (projectile_count - 1) * angle_between_projectiles
	var start_angle: float = - total_cone_angle / 2.0
	for i in range(projectile_count):
		var current_angle: float = start_angle + i * angle_between_projectiles
		var direction: Vector2 = shoot_direction.rotated(deg_to_rad(current_angle))
		var projectile: Projectile = projectile_scene.instantiate()
		projectile.speed = projectile_speed
		projectile.damage = projectile_damage
		projectile.direction = direction
		projectile.lifetime = projectile_lifetime
		get_tree().current_scene.add_child(projectile)
		projectile.global_position = global_position
	shoot_sound.play()
	is_shooting = false
	projectile_fired.emit()
	var effect: Node2D = spawn_effect.instantiate()
	effect.global_position = global_position
	effect.rotation = shoot_direction.angle()
	get_tree().current_scene.add_child(effect)


func set_active(active: bool) -> void:
	is_active = active


func is_ready_to_fire() -> bool:
	return is_active && time_since_last_shot >= time_between_shots
