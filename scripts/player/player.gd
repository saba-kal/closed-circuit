class_name Player extends CharacterBody2D

@export var speed: float = 400
@export var max_health: int = 3

var current_health: int


func _ready() -> void:
	current_health = max_health


func _physics_process(delta: float) -> void:
	var input_direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	move_and_slide()


func take_damage(damge: int) -> void:
	current_health -= damge
	print("player took damage")
	if current_health <= 0:
		SignalBus.game_over.emit()
		#queue_free()
