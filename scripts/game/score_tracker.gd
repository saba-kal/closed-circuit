class_name ScoreTracker extends Node

@export var score_label: Label


func _ready() -> void:
	PlayerData.current_score = 0
	score_label.text = "0"
	SignalBus.enemies_killed.connect(on_enemies_killed)
	SignalBus.game_over.connect(on_game_over)


func on_enemies_killed(enemies: Array[Enemy]) -> void:
	for enemy in enemies:
		PlayerData.current_score += len(enemies) * enemy.score_value
	score_label.text = str(PlayerData.current_score)
	if PlayerData.current_score > PlayerData.highest_score:
		PlayerData.highest_score = PlayerData.current_score


func on_game_over() -> void:
	score_label.visible = false
