@tool
extends Node2D

@export var spawn_box: Rect2:
	set(new_value):
		spawn_box = new_value
		if Engine.is_editor_hint():
			queue_redraw()
@export var possible_enemies: Array[PackedScene]
@export var time_between_spawns: float = 5

var spawning_enabled: bool = false
var time_since_last_spawn: float = 0


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	SignalBus.enemy_killed.connect(on_enemy_killed)
	SignalBus.game_over.connect(on_game_over)


func _process(delta: float) -> void:
	if Engine.is_editor_hint() or !spawning_enabled:
		return

	if time_since_last_spawn >= time_between_spawns:
		spawn_random_enemies()
		time_since_last_spawn = 0
	time_since_last_spawn += delta


func on_enemy_killed(_enemy: Enemy) -> void:
	# We only need to know when the first enemy is killed so that we can start spawning.
	SignalBus.enemy_killed.disconnect(on_enemy_killed)
	spawning_enabled = true


func on_game_over() -> void:
	spawning_enabled = false


func _draw():
	if Engine.is_editor_hint():
		draw_rect(spawn_box, Color(0, 1, 0, 0.5), false, 5.0)


func spawn_random_enemies() -> void:
	var rng := RandomNumberGenerator.new()
	var randi: int = rng.randi_range(0, len(possible_enemies) - 1)
	var enemy = possible_enemies[randi].instantiate()
	add_child(enemy)
	var x: int = rng.randi_range(spawn_box.position.x, spawn_box.position.x + spawn_box.size.x)
	var y: int = rng.randi_range(spawn_box.position.y, spawn_box.position.y + spawn_box.size.y)
	enemy.global_position =  global_position + Vector2(x,y)
