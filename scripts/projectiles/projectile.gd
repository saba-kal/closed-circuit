class_name Projectile extends Area2D

@export var is_stationary: bool = false

var direction: Vector2 = Vector2.UP
var speed: float = 500
var damage: int = 1
var lifetime: float = 5
var time_since_spawn: float = 0


func _ready() -> void:
	body_entered.connect(on_body_entered)


func _process(delta: float) -> void:
	if is_stationary:
		return
	if time_since_spawn >= lifetime:
		queue_free()
	time_since_spawn += delta


func _physics_process(delta: float) -> void:
	if is_stationary:
		return
	global_position += direction * speed * delta


func on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	if is_stationary:
		return
	queue_free()
