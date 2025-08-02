class_name Player extends CharacterBody2D

signal health_changed(new_health: int)

@export var speed: float = 400
@export var max_health: int = 3
@export var immunity_duration: float = 1.0
@export_flags_2d_physics var immunity_layer: int

@onready var player_hit_sound: AudioStreamPlayer = $PlayerHitSound

var current_health: int
var is_immune: bool = false
var time_immune: float = 0
var default_collision_layer: int


func _ready() -> void:
	current_health = max_health
	default_collision_layer = collision_layer


func _process(delta: float) -> void:
	if is_immune:
		if time_immune >= immunity_duration:
			is_immune = false
			collision_layer = default_collision_layer
			modulate.a = 1.0
		time_immune += delta


func _physics_process(delta: float) -> void:
	var input_direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	move_and_slide()


func take_damage(damge: int) -> void:
	if is_immune:
		return
	current_health -= damge
	health_changed.emit(current_health)
	player_hit_sound.play()
	HitStopManager.frame_freeze(0.1, 0.2)
	if current_health <= 0:
		SignalBus.game_over.emit()
		queue_free()
	else:
		SignalBus.player_damaged.emit()
		is_immune = true
		collision_layer = immunity_layer
		modulate.a = 0.3
		time_immune = 0
