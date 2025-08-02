class_name Player extends CharacterBody2D

signal health_changed(new_health: int)

@export var speed: float = 400
@export var max_health: int = 3

@onready var player_hit_sound: AudioStreamPlayer = $PlayerHitSound

var current_health: int


func _ready() -> void:
	current_health = max_health


func _physics_process(delta: float) -> void:
	var input_direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	move_and_slide()


func take_damage(damge: int) -> void:
	current_health -= damge
	health_changed.emit(current_health)
	player_hit_sound.play()
	HitStopManager.frame_freeze(0.1, 0.2)
	if current_health <= 0:
		SignalBus.game_over.emit()
		queue_free()
	else:
		SignalBus.player_damaged.emit()
