@tool
extends Node2D

@export var spawn_box: Rect2:
	set(new_value):
		spawn_box = new_value
		if Engine.is_editor_hint():
			queue_redraw()
@export var spawn_data_per_difficulty: Array[EnemySpawnData]
@export var spawn_immediately: bool = false

var spawning_enabled: bool = false
var time_since_last_spawn: float = 0
var difficulty_level: int = 0
var enemies_killed: int = 0
var player: Player


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	player = get_tree().get_first_node_in_group("player")
	SignalBus.enemy_killed.connect(on_enemy_killed)
	SignalBus.game_over.connect(on_game_over)
	if spawn_immediately:
		spawning_enabled = true


func _process(delta: float) -> void:
	if Engine.is_editor_hint() or !spawning_enabled:
		return

	var spawn_data: EnemySpawnData = spawn_data_per_difficulty[difficulty_level]
	if time_since_last_spawn >= spawn_data.time_between_spawns and get_child_count() < spawn_data.max_enemies:
		spawn_random_enemies()
		time_since_last_spawn = 0
	time_since_last_spawn += delta


func on_enemy_killed(_enemy: Enemy) -> void:
	spawning_enabled = true
	enemies_killed += 1
	#Move to the next difficulty level
	if enemies_killed >= spawn_data_per_difficulty[difficulty_level].kill_count_for_next_difficulty:
		difficulty_level = min(len(spawn_data_per_difficulty) - 1, difficulty_level + 1)
		enemies_killed = 0
		print("New difficulty level: " + str(difficulty_level))
		if spawn_data_per_difficulty[difficulty_level].boss_spawn:
			spawn_boss(spawn_data_per_difficulty[difficulty_level].boss_spawn)


func on_game_over() -> void:
	spawning_enabled = false


func _draw():
	if Engine.is_editor_hint():
		draw_rect(spawn_box, Color(0, 1, 0, 0.5), false, 5.0)


func spawn_random_enemies() -> void:
	var spawn_data: EnemySpawnData = spawn_data_per_difficulty[difficulty_level]
	var rng := RandomNumberGenerator.new()
	for i in range(spawn_data.enemies_per_spawn):
		var randi: int = rng.randi_range(0, len(spawn_data.spawnable_enemies) - 1)
		var enemy: Node2D = spawn_data.spawnable_enemies[randi].instantiate()
		var x: int = rng.randi_range(spawn_box.position.x, spawn_box.position.x + spawn_box.size.x)
		var y: int = rng.randi_range(spawn_box.position.y, spawn_box.position.y + spawn_box.size.y)
		enemy.global_position =  global_position + Vector2(x,y)
		add_child(enemy)


func spawn_boss(boss_scene: PackedScene) -> void:
	var rng := RandomNumberGenerator.new()
	var boss: Enemy = boss_scene.instantiate()
	var angle = rng.randf_range(0, PI * 2)
	var target_pos = player.global_position + Vector2(cos(angle), sin(angle)) * 1000
	boss.global_position = target_pos
	boss.follow_player_on_wander = true
	add_child(boss)
