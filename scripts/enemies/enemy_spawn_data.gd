class_name EnemySpawnData extends Resource

@export var spawnable_enemies: Array[PackedScene]
@export var boss_spawn: PackedScene
@export var max_enemies: int = 25
@export var time_between_spawns: float = 1
@export var enemies_per_spawn: int = 1
@export var kill_count_for_next_difficulty: int = 10
